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
  bool _isLoading=false;
  final formKey=GlobalKey<FormState>();
  String email="";
  String password="";
  String fullName="";
  AuthService authService=AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
     // body: Center(child: Text("login page")),

     body: _isLoading?Center (child:CircularProgressIndicator(color: Theme.of(context).primaryColor)):SingleChildScrollView(
        child:Padding(
          padding:const EdgeInsets.symmetric(horizontal: 20,vertical: 10) ,
          child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    const Text(
                      "संवाद",
                      style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold)
                    ),
                      const SizedBox(height: 5),
                      const Text("Create your account now to see what people are talking about!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize:15,fontWeight:FontWeight.w400)),
                        const SizedBox(height:20),
                      Image.asset("assets/main1.png"),
                      const SizedBox(height: 5),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          labelText: "FullName",
                          prefixIcon: Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                          )
                        ),
                        onChanged: (val){
                          setState(() {
                            fullName=val;
                            print(fullName);

                          });
                        },

                        validator: (val){
                          //return RegExp("").hasMatch(val!)?null:"Please enter a valid email";
                          if(val!.isNotEmpty){
                            return null;

                          }else{
                            return "Name cannot be empty";
                          }
                        },
                      ),


                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          labelText: "Email",
                          prefixIcon: Icon(
                            Icons.email,
                            color: Theme.of(context).primaryColor,
                          )
                        ),
                        onChanged: (val){
                          setState(() {
                            email=val;
                            print(email);

                          });
                        },

                        validator: (val){
                          return RegExp("").hasMatch(val!)?null:"Please enter a valid email";
                        },
                      ),


                      const SizedBox(height: 10),
                      TextFormField(
                        obscureText: true,
                        decoration: textInputDecoration.copyWith(
                          labelText: "Password",
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Theme.of(context).primaryColor,
                          )
                        ),

                        validator: (val){
                          if(val!.length<6){
                            return "password must be at least 6 character";
                          }else{
                            return null;
                          }
                        },
                        onChanged: (val){
                          setState(() {
                            password=val;
                            print(password);

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
                            borderRadius: BorderRadius.circular(30)
                          )
                        ),
                        
                        
                        child: const Text("Register",style:TextStyle(color:Colors.white,fontSize: 16)
                        ),
                        onPressed: (){
                          register();
                        },
                        ),
                    ),
                    const SizedBox(height: 10, ),
                    Text.rich(TextSpan(
                      text: "Already have an account?  ",
                      style: const TextStyle(color: Colors.black,fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text:"Login Now",
                          style: const TextStyle(color: Color.fromARGB(255, 6, 68, 161),decoration: TextDecoration.underline,fontWeight:FontWeight.bold),
                          recognizer: TapGestureRecognizer()..onTap=(){
                            nextScreen(context, const LoginPage());
                          }
                        )
                      ]
                    ))

                    
                ],

              ),

          ),
          
          ),
      
       ),
    );
  }
  register() async{
    if(formKey.currentState!.validate()){
      setState(() {
        _isLoading=true;
      });
      await authService.registerUserwithEmailandPassword(fullName, email, password).then  ((value) async{
        if(value==true){
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(fullName);
         // nextScreenReplace(context,const HomePage());
          nextScreenReplace(context,const LoginPage());
          showSnackbar(context, Colors.green, "Registration  successfull.");
       
        }else{
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading=false;
          });
        }
      });
    }
  }
}