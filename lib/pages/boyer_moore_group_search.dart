import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sambaad/helper/helper_function.dart';
import 'package:sambaad/pages/chat_page.dart';
import 'package:sambaad/services/database_services.dart';
import 'package:sambaad/widgets/widgets.dart';

import '../algorithm/boyre_moore.dart';

class BMSearchPage extends StatefulWidget {
  const BMSearchPage({super.key});

  @override
  State<BMSearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<BMSearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  User? user;

  List<DocumentSnapshot> searchGroup(
      String searchText, QuerySnapshot snapshot) {
    List<DocumentSnapshot> result = [];
    if (searchText.isNotEmpty) {
      for (final DocumentSnapshot group in snapshot.docs) {
        if (BMAlgorithm.BoyerMoore(
            searchText.toLowerCase(), group.get('groupName').toLowerCase())) {
          result.add(group);
        }
      }
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
    searchController.addListener(() {
    if (searchController.text.isNotEmpty) {
      initiateSearchMethod();
    }
  });
  }

  getCurrentUserIdandName() async {
    await HelperFunction.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF3A98B9),
        title: const Text(
          "Search",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF3A98B9),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search groups....",
                        hintStyle:
                            TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Center(
                  heightFactor: 12,
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                )
              : groupList(),
        ],
      ),
    );
  }

//   initiateSearchMethod() async {
//   if (searchController.text.isNotEmpty) {
//     setState(() {
//       isLoading = true;
//     });
//     Timer(const Duration(milliseconds: 1000), () async {
//       await DatabaseServices().BMgroupSearchByName().then((snapshot) {
//         setState(() {
//           searchSnapshot = snapshot;
//           isLoading = false;
//           hasUserSearched = true;
//         });
//       });
//     });
//   }
// }

initiateSearchMethod() async {
  if (searchController.text.isNotEmpty) {
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 700), () async {
      await DatabaseServices().BMgroupSearchByName().then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasUserSearched = true;
        });
      });
    });
  }
}


  groupList() {
    return hasUserSearched
        ? searchGroup(searchController.text, searchSnapshot!).isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                itemCount:
                    searchGroup(searchController.text, searchSnapshot!).length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot group = searchGroup(
                      searchController.text, searchSnapshot!)[index];
                  return groupTile(
                    userName,
                    group.get('groupId'),
                    group.get('groupName'),
                    group.get('admin'),
                  );
                },
              )
            // ignore: avoid_unnecessary_containers
            : Container(
                child: const Center(
                  heightFactor: 20,
                  child: Text(
                    "Group not found",
                    style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 189, 178, 174)),
                  ),
                ),
              )
        : Container();
  }

  joinedOrNot(
      String userName, String groupId, String groupname, String admin) async {
    await DatabaseServices(uid: user!.uid)
        .isUserJoined(groupname, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    // function to check whether user already exists in group
    joinedOrNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Color(0xFF3A98B9),
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title:
          Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Admin: ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseServices(uid: user!.uid)
              .toggleGroupJoin(groupId, userName, groupName);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            // ignore: use_build_context_synchronously
            showSnackbar(context, Colors.green, "Successfully joined the group");
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
              showSnackbar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(255, 37, 216, 52),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Joined",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Join Now",
                    style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}
