import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  const MessageTile(
      {super.key,
      required this.message,
      required this.sender,
      required this.sentByMe});

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 10,
          right: widget.sentByMe ? 10 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
          padding:
              const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
          margin: widget.sentByMe
              ? const EdgeInsets.only(top: 8, bottom: 8, right: 10, left: 80)
              : const EdgeInsets.only(top: 8, bottom: 8, right: 80, left: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: widget.sentByMe
                      ? Radius.circular(23)
                      : Radius.circular(0),
                  bottomRight: widget.sentByMe
                      ? Radius.circular(0)
                      : Radius.circular(23)),
              color: widget.sentByMe ? Color(0xff075E54) : Colors.grey),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.sender.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          )),
    );
  }
}
