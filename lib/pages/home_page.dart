import 'package:flutter/material.dart';
import 'package:sambaad/helper/helper_function.dart';
import 'package:sambaad/pages/profile_page.dart';
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
                  nextScreenReplace(context, const SearchPage());
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
                  height: 0,
                  thickness: 1,
                ),
                ListTileTheme(
                  child: Column(
                    children: [
                      ListTile(
                        selected: true,
                        selectedTileColor: Color(0xff075E54),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        leading: const Icon(
                          Icons.group,
                          color: Colors.white,
                        ),
                        title: const Text("Groups",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                        onTap: () {
                          nextScreen(context, const HomePage());
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Color(0xff075E54),
                        ),
                        title: const Text("Profile",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff075E54))),
                        onTap: () {
                          // go to profile page
                          nextScreen(
                              context,
                              ProfilePage(
                                userName: userName,
                                email: email,
                              ));
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Color(0xff075E54),
                        ),
                        title: const Text("Logout",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff075E54))),
                        onTap: () async {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Logout"),
                                  content: const Text(
                                      "Are you sure you want to logout?"),
                                  actions: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.cancel,
                                          color:
                                              Color.fromARGB(255, 182, 28, 28)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Color(0xff075e54)),
                                      onPressed: () async {
                                        await authService.signOut();
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginPage()),
                                                (route) => false);
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                      ),
                    ],
                  ),
                ),
              ]),
        ));
  }
}
