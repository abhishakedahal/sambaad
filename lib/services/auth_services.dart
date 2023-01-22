import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sambaad/helper/helper_function.dart';
import 'package:sambaad/services/database_services.dart';

class AuthService{
  final FirebaseAuth firebaseAuth=FirebaseAuth.instance;

  //login
  Future loginUserWithEmailandPassword(String email,String password) async{
      try{
        User user=(await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;


      if(user!=null){
        return true;
      }
      }on FirebaseAuthException catch(e){
       // print(e);
        return e.message;
      }
    }


  //register
  Future registerUserwithEmailandPassword(
    String fullName,String email,String password)async{
      try{
        User user=(await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;


      if(user!=null){
       await DatabaseServices(uid:user.uid).savingUserData(fullName, email);
        return true;
      }
      }on FirebaseAuthException catch(e){
       // print(e);
        return e.message;
      }
    }


  //signout
  Future signout() async{
    try{
      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserEmailSF("");
      await HelperFunction.saveUserNameSF("");
    }catch(e){
      return null;
    }
  }
}