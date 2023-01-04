import 'package:flutter/material.dart';
import 'package:sambaad/pages/profile_page.dart';
import 'package:sambaad/pages/search_page.dart';
import 'package:sambaad/services/auth_services.dart';
import 'package:sambaad/widgets/widgets.dart';

import '../helper/helper_function.dart';
import 'login_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   AuthService authService=AuthService();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //body: Center(child: Text("Home Page")),
//      appBar: AppBar(
//       actions: [
//         IconButton(onPressed: (){
//           nextScreen(context,const Searchpage());
//         }, icon: const Icon(
//           Icons.search,
//         ))
//       ],
//       elevation: 0,
//       centerTitle: true,
//       backgroundColor: Theme.of(context).primaryColor,
//       title: Text("संवाद",style:TextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 27) ,),
//      ),
//      drawer: Drawer(
//       child: ListView(
//         padding: const EdgeInsets.symmetric(vertical:50),

//       ),
//      ),
//     );
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String userName="";
  String email="";

  AuthService authService=AuthService();
  @override
  void initState(){
    super.initState();
    gettingUserData();
  }

  
  gettingUserData() async{
    await HelperFunction.getUserEmailFromSF().then((value){
      setState(() {
        email=value!;
      });
    });
    await HelperFunction.getUserNameFromSF().then((val) { //value or val
      setState(() {
        userName=val!;
      });
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      //body: Center(child: Text("Home Page")),
     appBar: AppBar(
      actions: [
        IconButton(onPressed: (){
          nextScreen(context,const Searchpage());
        }, icon: const Icon(
          Icons.search,
        ))
      ],
      elevation: 0,
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text("संवाद",style:TextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 27) ,),
     ),
     drawer: Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical:50),
        children: <Widget>[
          Icon(
              Icons.account_circle,
              size:150,
              color:Colors.grey[700],
          ),
          const SizedBox(
            height: 15,
          ),
          Text(userName,textAlign:TextAlign.center,style: const TextStyle(fontWeight: FontWeight.bold),),
          const SizedBox(
            height: 30,
          ),
          const Divider(
            height: 2,
          ),
          ListTile(
            onTap: (){},
            selectedColor: Theme.of(context).primaryColor,
            selected: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            leading: const Icon(Icons.group),
            title: const Text(
              "Friends",style: TextStyle(color: Colors.black),
            ),
          ),

          //for profile page
          ListTile(
            onTap: (){
              nextScreenReplace(context, ProfilePage(userName: userName,email: email,));
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            leading: const Icon(Icons.person),
            title: const Text(
              "Profile",style: TextStyle(color: Colors.black),
            ),
          ),


          //For logout
          ListTile(
            onTap: ()async{
              showDialog(
                barrierDismissible:false,
                context: context, 
                builder: (context){
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                       
                        IconButton(
                          onPressed: () async {
                            await authService.signout();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false);
                          },
                          icon: const Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ),
                         IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    );
                });
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            leading: const Icon(Icons.exit_to_app),
            title: const Text(
              "Logout",style: TextStyle(color: Colors.black),
            ),
          ),
        ],

      ),
     ),
    );
  }
}