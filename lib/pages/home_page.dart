import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sambaad/pages/profile_page.dart';
// import 'package:sambaad/pages/search_page.dart';
import 'package:sambaad/services/auth_services.dart';
import 'package:sambaad/pages/boyer_moore_group_search.dart';
import 'package:sambaad/pages/search_page.dart';
import 'package:sambaad/services/database_services.dart';
import 'package:sambaad/widgets/group_title.dart';
import 'package:sambaad/widgets/widgets.dart';
import '../helper/helper_function.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  //const HomePage({super.key});
  const HomePage({Key? key}) : super(key: key);

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
    await HelperFunction.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunction.getUserNameFromSF().then((val) {
      //value or val
      setState(() {
        userName = val!;
      });
    });
    // getting the list of snapshots in our stream
    await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      //body: Center(child: Text("Home Page")),
      appBar: AppBar(      
        actions: [
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(                
                  title: Text("Search Options",),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          nextScreen(context, SearchPage());
                        },
                        title: Text("Normal Search"),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          nextScreen(context, BMSearchPage());
                        },
                        title: Text("Boyer Moore Search"),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          icon: Icon(
            Icons.search,
            size: 30,
          ),
        )
      ],
        elevation: 0,
        backgroundColor: Color(0xFF3A98B9), toolbarHeight: 60,
        centerTitle: true, 
        title: Text(
          "संवाद",
          style: TextStyle(fontSize: 30),
        ),
      ),

      drawer:  Drawer(                     
          child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),           
          children: <Widget>[
              Icon(
              Icons.account_circle,
              size: 150,
              color: Color(0xFF3A98B9),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {
                nextScreenReplace(
                    context,
                    HomePage(
                    
                    ));
              },
              selectedColor:Color(0xFF3A98B9),
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),

            //for profile page
            ListTile(
              onTap: () {
                nextScreenReplace(
                    context,
                    ProfilePage(
                      userName: userName,
                      email: email,
                    ));
              },
              selectedColor:Color(0xFF3A98B9),
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.person),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),

            //For logout
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
                        title: const Text("Logout"),
                        content: const Text("Are you sure to logout from संवाद?"),
                        actions: [
                          IconButton(
                            onPressed: () async {
                              await authService.signout();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                  (route) => false);
                              showSnackbar(context, Colors.green,
                                "Logout  successfully.");
                               
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
              selectedColor:Color(0xFF3A98B9),
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
     
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 5,
        backgroundColor: Color(0xFF3A98B9),
          child: const Icon(
          Icons.person_add,
          color: Colors.white,
          size: 31,
        ),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              title: const Text(
                "Create a group",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF3A98B9),
                        ),)
                      : TextField(                        
                          onChanged: (val) {                            
                            setState(() {
                              groupName = val;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFF3A98B9)),
                                  borderRadius: BorderRadius.circular(20)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Color(0xFF3A98B9)),
                                  borderRadius: BorderRadius.circular(20)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFF3A98B9)),
                                  borderRadius: BorderRadius.circular(20))),
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3A98B9),),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (groupName != "") {
                      setState(() {
                        _isLoading = true;
                      });
                      DatabaseServices(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .createGroup(userName,
                              FirebaseAuth.instance.currentUser!.uid, groupName)
                          .whenComplete(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                      showSnackbar(
                          context, Colors.green, "Group created successfully.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3A98B9),),
                  child: const Text("CREATE"),
                )
              ],
            );
          }));
        });
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
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
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any groups, tap on the add icon to create a group or also search from top search button.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
