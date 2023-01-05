import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sambaad/pages/auth/register_page.dart';
import 'package:sambaad/service/auth_service.dart';
import 'package:sambaad/service/database_service.dart';
import 'package:sambaad/widgets/widgets.dart';
import '../../helper/helper_function.dart';
import '../home_page.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  final formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";

  bool _isLoading = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                  const Text("Logging in..."),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text("संवाद",
                            style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff075E54))),
                        const SizedBox(height: 10),
                        const Text(
                            "Log in and start conversing instantly! No barriers, no limits!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            )),
                        Image.asset("assets/main.png"),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                            prefixIcon: const Icon(Icons.email,
                                color: Color(0xff075E54)),
                            labelText: 'Email',
                            //add color
                          ),
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },

                          //check the email is valid or not
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val!)
                                ? null
                                : "Please enter a valid email";
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          obscureText: _obscureText,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock,
                                color: Color(0xff075E54)),
                            suffixIcon: IconButton(
                              color: const Color(0xff075E54),
                              icon: Icon(_obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),

                          //check the password is valid or not
                          validator: (val) {
                            return val!.length < 6
                                ? "Password must be 6+ characters"
                                : null;
                          },

                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                            onPressed: () {
                              login();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text.rich(TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "Register here",
                                style: const TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const RegisterPage());
                                  }),
                          ],
                        )),
                        Text.rich(TextSpan(
                          text: "Forgot Your Password? ",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "Reset Password",
                                style: const TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, ForgotPasswordScreen());
                                  }),
                          ],
                        )),
                      ],
                    )),
              ),
            ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginUserWithEmailandPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(email);

          //saving the values to shared preferences

          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(snapshot.docs[0].get("fullName"));

          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
