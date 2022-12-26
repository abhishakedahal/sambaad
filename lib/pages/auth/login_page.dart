import 'package:flutter/material.dart';
import 'package:flutter_practise/shared/constants.dart';
import 'package:flutter_practise/widgets/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text("संवाद",
                      style:
                          TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                      "Bringing the world closer together, one conversation at a time",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      )),
                  Image.asset("assets/main.png"),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      prefixIcon:
                          const Icon(Icons.email, color: Color(0xff075E54)),
                      labelText: 'Email',
                      //add color
                    ),
                    onChanged: (val) {
                      setState(() {
                         email=val;
                    });
                    },

                  

                  ),
                  
                  const SizedBox(height: 15),
                  TextFormField(
                    obscureText: _obscureText,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock, color: Color(0xff075E54)),
                      suffixIcon: IconButton(color: const Color(0xff075E54),
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
                    onChanged: (val) {
                      setState(() {
                         password=val;
                    });
                    },
                  )
                ],
              )),
        ),
      ),
    );
  }
}
