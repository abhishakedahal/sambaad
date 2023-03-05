import 'package:flutter/material.dart';

const textInputDecoration=InputDecoration(
  labelStyle: TextStyle(color:Colors.black,fontWeight: FontWeight.w100),
  focusedBorder: OutlineInputBorder(
   // borderSide: BorderSide(color: Color(0xFFee7b64),width: 2),
    borderSide: BorderSide(color: Color(0xFF3A98B9),width: 2),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF3A98B9),width: 2, ),
     ),

  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF3A98B9),width: 2),
  )
);


void nextScreen(context,page){
  Navigator.push(context, MaterialPageRoute(builder: (context)=>page));
}

void nextScreenReplace(context,page){
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>page));
}

void showSnackbar(context,Color,message){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content:Text(message,style:const TextStyle(fontSize: 14),
        ),
    backgroundColor:Color,
    duration: const Duration(seconds: 2),
    action: SnackBarAction(label: "OK", onPressed:() {},
    textColor:Colors.white, 
        
  )
  ));
}