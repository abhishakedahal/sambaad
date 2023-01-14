import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sambaad/helper/helper_function.dart';
import 'package:sambaad/pages/profile_page.dart';
import 'package:sambaad/pages/search_page.dart';
import 'package:sambaad/service/auth_service.dart';
import 'package:sambaad/service/database_service.dart';
import 'package:sambaad/widgets/group_tile.dart';
import 'package:sambaad/widgets/widgets.dart';
import 'package:sambaad/pages/auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";

  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
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
    //getting the list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
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
                                          color: Color(0xff075E54)),
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
        ),
        body: groupList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            popUpDialog(context);
          },
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ));
  }

  popUpDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: ((context, setState) {
              return AlertDialog(
                title: const Text("Create a new group"),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor),
                        )
                      : TextField(
                          onChanged: (val) {
                            setState(() {
                              groupName = val;
                            });
                          },
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(5)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2,
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(5)),
                            errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(5)),
                            hintText: "Group Name",
                          ),
                        ),
                ]),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text("Cancel")),
                  ElevatedButton(
                      onPressed: () async {
                        if (groupName != "") {
                          setState(() {
                            _isLoading = true;
                          });
                          DatabaseService(
                                  uid: FirebaseAuth.instance.currentUser!.uid)
                              .createGroup(
                                  userName,
                                  FirebaseAuth.instance.currentUser!.uid,
                                  groupName)
                              .whenComplete(() => _isLoading = false);
                          Navigator.of(context).pop();
                          showSnackbar(context, Colors.green,
                              "Group created successfully");
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text("Create"))
                ],
              );
            }),
          );
        });
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (BuildContext context, int index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                      groupId: getId(snapshot.data['groups'][reverseIndex]),
                      groupName: getName(snapshot.data['groups'][reverseIndex]),
                      userName: snapshot.data['fullName']);
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xff075E54)));
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => {
                popUpDialog(context),
              },
              child: const Icon(
                Icons.add_circle,
                color: Color.fromARGB(188, 3, 76, 60),
                size: 75,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "You have no groups. Tap on the add icon to create a new group or search for an existing group",
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(188, 3, 76, 60)),
              textAlign: TextAlign.center,
            )
          ],
        ));
  }
}
