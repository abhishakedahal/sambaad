import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatefulWidget {
  final Widget message;
  final String sender;
  final bool sentByMe;
  final int time;

  const MessageTile({
    Key? key,
    required this.message,
    required this.sender,
    required this.sentByMe,
    required this.time,
  }) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 15,
          bottom: 15,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 12, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: widget.sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
            color: widget.sentByMe
                ? Theme.of(context).primaryColor
                : Colors.grey[700]),

        //for sender and receiver name and message
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sender.toUpperCase(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            // Text(widget.message,
            //     textAlign: TextAlign.start,
            //     style: const TextStyle(fontSize: 16, color: Colors.white)),
            widget.message,
            const SizedBox(height: 8),
            Text(
              dateDifference(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String dateDifference() {
    var widgetTime = DateTime.fromMillisecondsSinceEpoch(widget.time)
        .toLocal()
        .toUtc()
        .add(Duration(hours: 5, minutes: 45));
    var currentTime = DateTime.now();
    var difference = currentTime.difference(widgetTime).inMinutes;

    if (difference <= 60) {
      return "${DateFormat.jm().format(widgetTime)}";
    } else if (difference > 60 && difference < 1440) {
      return "${(difference / 60).floor()} hours ago";
    } else {
      return "${DateFormat.yMMMd().format(widgetTime)} at ${DateFormat.jm().format(widgetTime)}";
    }
  }
}
