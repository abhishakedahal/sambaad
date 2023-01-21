//import firebase_core and cloud_firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference to the collections
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  //saving the user data
  Future savingUserData(String fullName, String email) async {
    return await usersCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await usersCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //get user groups
  getUserGroups() async {
    return usersCollection.doc(uid).snapshots();
  }

  //creating a group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupdocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupid": "",
      "recentMessage": "",
      "recentMessageSender": "",
      "recentMessageTime": "",
    });

    //updating the group id and members
    await groupdocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupid": groupdocumentReference.id,
    });

    DocumentReference userDocumentReference = usersCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupdocumentReference.id}_$groupName"]),
    });
  }

  //get the chats

  getChats(String groupId) async {
    return groupCollection.doc(groupId).collection("messages").orderBy("time").snapshots(); 
  }

  // get the admin
  Future getGroupAdmin(String groupId ) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  //get group members
  getGroupMembers(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['members'];
  }

  void leaveGroup(String groupId, String adminName) {
    DocumentReference d = groupCollection.doc(groupId);
    d.update({
      "members": FieldValue.arrayRemove(["${uid}_$adminName"]),
    });
    DocumentReference userDocumentReference = usersCollection.doc(uid);
    userDocumentReference.update({
      "groups": FieldValue.arrayRemove(["${groupId}_$adminName"]),
    });
  }

}
