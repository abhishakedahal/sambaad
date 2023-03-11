import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sambaad/helper/helper_function.dart';
import 'package:sambaad/pages/home_page.dart';
import 'package:sambaad/pages/login_page.dart';
import 'package:sambaad/services/auth_services.dart';

import '../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
  AuthService authService = AuthService();

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
                  color: Theme.of(context).primaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 5),
                      Image.asset("assets/main.png"),
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
                              labelText: "FullName",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0xFF3A98B9),
                              )),
                          onChanged: (val) {
                            setState(() {
                              fullName = val;
                              print(fullName);
                            });
                          },
                          validator: (val) {
                            //return RegExp("").hasMatch(val!)?null:"Please enter a valid email";
                            if (val!.isNotEmpty) {
                              return null;
                            } else {
                              return "Name cannot be empty";
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
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
                                padding: const EdgeInsets.all(17.10),
                                backgroundColor: Color(0xFF3A98B9),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: const Text("Register",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900)),
                            onPressed: () {
                              register();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      Text.rich(TextSpan(
                          text: "Already have an account?  ",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          children: <TextSpan>[
                            TextSpan(
                                text: "Login Now",
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 6, 68, 161),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreenReplace(
                                        context, const LoginPage());
                                  })
                          ]))
                    ],
                  ),
                ),
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
          .registerUserwithEmailandPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(fullName);
          // nextScreenReplace(context,const HomePage());
          nextScreenReplace(context, const LoginPage());
          showSnackbar(
            context,
            Color.fromARGB(255, 6, 180, 64),
            "Registred  Successfully.",
          );
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
