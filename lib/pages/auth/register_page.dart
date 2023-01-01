import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sambaad/helper/helper_function.dart';
import 'package:sambaad/service/auth_service.dart';

import '../../widgets/widgets.dart';
import '../home_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  bool _obscureText = true;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
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
                const Text("Registering..."),
              ],
            ))
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
                            "Create your account now to see what people are talking about!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            )),
                        Image.asset("assets/main.png"),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                            prefixIcon: const Icon(Icons.person,
                                color: Color(0xff075E54)),
                            labelText: 'Full Name',
                          ),
                          onChanged: (val) {
                            setState(() {
                              fullName = val;
                            });
                          },
                          validator: (val) {
                            return val!.isNotEmpty
                                ? null
                                : "Name cannot be empty!!";
                          },
                        ),
                        const SizedBox(height: 15),
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
                                "Register",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                            onPressed: () {
                              register();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text.rich(TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "Login",
                                style: const TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const LoginPage());
                                  }),
                          ],
                        )),
                      ],
                    )),
              ),
            ),
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerUserWithEmailandPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          //saving the shared preferences state
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(fullName);
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
