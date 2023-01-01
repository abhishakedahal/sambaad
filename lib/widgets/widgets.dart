import 'package:flutter/material.dart';
import 'package:sambaad/shared/constants.dart';

const textInputDecoration = InputDecoration(
    labelStyle: TextStyle(
      color: Colors.black,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xff075E54), width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide:
          BorderSide(color: Color.fromARGB(255, 174, 196, 186), width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2.0),
    ));

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(message, style: const TextStyle(fontSize: 14)),
      duration: const Duration(seconds: 10),
      action: SnackBarAction(
        label: 'Ok',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      )));
}
