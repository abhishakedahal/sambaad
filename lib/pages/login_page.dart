import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sambaad/pages/home_page.dart';
import 'package:sambaad/pages/register_page.dart';
import 'package:sambaad/services/auth_services.dart';
import 'package:sambaad/services/database_services.dart';
import 'package:sambaad/widgets/widgets.dart';

import '../helper/helper_function.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  bool? check3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3A98B9),
        toolbarHeight: 80,
        centerTitle: true,
        title: Text(
          "संवाद",
          style: TextStyle(fontSize: 60),
        ),
      ),
      // body: Center(child: Text("login page")),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Color(0xFF3A98B9),
          height: 55,
        ),
      ),

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //const Text("Login and start conversing instantly! No barriers, no limits!",
                    const SizedBox(height: 5),
                    Image.asset("assets/main.png"),
                    const SizedBox(height: 5),
                    const Text("केही मीठो बात गरौँ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 0),
                      child: TextFormField(
                        decoration: textInputDecoration.copyWith(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2,
                                  color: Color(0xFF3A98B9)), //<-- SEE HERE
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Color(0xFF3A98B9)),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Color(0xFF3A98B9)),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Color(0xFF3A98B9)),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            labelText: "Email",
                            prefixIcon: Icon(
                              Icons.email,
                              color: Color(0xFF3A98B9),
                            )),
                        onChanged: (val) {
                          setState(() {
                            email = val;
                            print(email);
                          });
                        },
                        validator: (val) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(val!)
                              ? null
                              : "Please enter a valid email";
                        },
                        onFieldSubmitted: (value) {
                          login();
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 0),
                      child: TextFormField(
                        obscureText: true,
                        decoration: textInputDecoration.copyWith(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Color(0xFF3A98B9)),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Color(0xFF3A98B9)),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Color(0xFF3A98B9)),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Color(0xFF3A98B9)),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            labelText: "Password",
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color(0xFF3A98B9),
                            )),
                        validator: (val) {
                          if (val!.length < 6) {
                            return "password must be at least 6 character";
                          } else {
                            return null;
                          }
                        },
                        onChanged: (val) {
                          setState(() {
                            password = val;
                            print(password);
                          });
                        },
                        onFieldSubmitted: (value) {
                          login();
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Color(0xFF3A98B9),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: Padding(
                            padding: const EdgeInsets.all(17.10),
                            child: const Text("LogIn",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900)),
                          ),
                          onPressed: () {
                            login();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text.rich(TextSpan(
                        text: "New to संवाद?  ",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                        children: <TextSpan>[
                          TextSpan(
                              text: "Create an account",
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 6, 68, 161),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  nextScreenReplace(
                                      context, const RegisterPage());
                                })
                        ]))
                  ],
                ),
              ),
            ),
    );
  }

  login() async {
    //return "login success";
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginUserWithEmailandPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot = await DatabaseServices(
                  uid: FirebaseAuth.instance.currentUser!.uid)
              .gettingUserData(email);

          //saving the values to our shared preferences
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(snapshot.docs[0]['fullName']);

          nextScreenReplace(context, const HomePage());
          showSnackbar(context, Colors.green, "Logged in successfully.");
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
