import 'package:flutter/material.dart';
import 'package:sambaad/helper/helper_function.dart';
import 'package:sambaad/pages/search_page.dart';
import 'package:sambaad/service/auth_service.dart';
import '../widgets/widgets.dart';
import 'auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";

  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    await HelperFunction.getUserEmailSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunction.getUserNameSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            IconButton(
                onPressed: () {
                  nextScreen(context, const SearchPage());
                },
                icon: const Icon(Icons.search))
          ],
          elevation: 1,
          centerTitle: true,
          title: const Text(
            "Groups",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        drawer: Drawer(
          child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 50),
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(userName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff075E54),
                    )),
                const SizedBox(height: 30),
                const Divider(
                  height: 30,
                  thickness: 1,
                ),
                ListTileTheme(
                  child: Column(
                    children: [
                      ListTile(
                        selectedColor: Color(0xff075E54),
                        selected: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        leading: const Icon(
                          Icons.group,
                        ),
                        title: const Text("Groups",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff075E54))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.person,
                        ),
                        title: const Text("Profile",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff075E54))),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                        ),
                        title: const Text("Logout",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff075E54))),
                        onTap: () async {
                          authService.signOut().whenComplete(() =>
                              nextScreenReplace(context, const LoginPage()));
                        },
                      ),
                    ],
                  ),
                ),
              ]),
        ));
  }
}
