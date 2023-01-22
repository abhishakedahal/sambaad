import 'package:flutter/material.dart';
import 'package:sambaad/pages/chat_page.dart';
import 'package:sambaad/widgets/widgets.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;

  const GroupTile(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(context, ChatPage(
          groupId: widget.groupId,
          groupName: widget.groupName,
          userName: widget.userName,
        ));
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xff075E54),
              child: Text(
                widget.groupName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            title: Text(
              widget.groupName,
              style: const TextStyle(
                color: Color(0xff075E54),
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              "Join the conversation as ${widget.userName}",
              style: const TextStyle(
                color: Color.fromARGB(255, 144, 161, 159),
                fontSize: 14,
              ),
            ),
          )),
    );
  }
}
