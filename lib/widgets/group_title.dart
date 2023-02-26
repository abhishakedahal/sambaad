import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sambaad/pages/chat_page.dart';
import 'package:sambaad/widgets/widgets.dart';
import '../services/database_services.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const GroupTile({Key? key,
        required this.groupId,
        required this.groupName,
        required this.userName }):super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {

String recentMessage = "";
  String recentMessageSender = "";
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 0), (_) {
      setState(() {
        getRecentMessageAndSender();
      });
    });
  }

  getRecentMessageAndSender() {
    DatabaseServices().getRecentMessage(widget.groupId).then((val) {
      setState(() {
        recentMessage = val.length>30? val.substring(0,30)+" .....":val;
      });
    });
    DatabaseServices().getRecentMessageSender(widget.groupId).then((val) {
      setState(() {
        recentMessageSender = val;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupId: widget.groupId,
              groupName: widget.groupName,
              userName: widget.userName,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.groupName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(
            widget.groupName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle:
          recentMessageSender == "" && recentMessage == ""
              ? const Text("No recent messages")
              :
           Text(
            "$recentMessageSender: $recentMessage",
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}