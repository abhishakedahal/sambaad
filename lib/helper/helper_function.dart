import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction{

  static String userLoggedInKey="LOGGEDINKEY";
  static String userNameKey="USERNAMEKEY";
  static String userEmailKey="USEREMAILKEY";


  static Future<bool?> getUserLoggedInstatus() async{
    SharedPreferences sf=await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }
}