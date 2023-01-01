import 'package:flutter/material.dart';
import 'package:sambaad/pages/search_page.dart';
import 'package:sambaad/services/auth_services.dart';
import 'package:sambaad/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService=AuthService();
  @override
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

      ),
     ),
    );
  }
}