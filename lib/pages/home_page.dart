import 'package:flutter/material.dart';
import 'package:flutter_practise/service/auth_service.dart';
import '../widgets/widgets.dart';
import 'auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
        child: const Text("Logout"),
        onPressed: () {
          authService.signOut();

          // go to login screen
          nextScreenReplace(context, const LoginPage());
        },
      )),
    );
  }
}
