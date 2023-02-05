import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sambaad/pages/group_info.dart';
import 'package:sambaad/services/database_services.dart';
import 'package:sambaad/widgets/message_tile.dart';
import 'package:sambaad/widgets/widgets.dart';
import 'package:sambaad/pages/search_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AESEncryption {
  static encryptAES(plainText) {
    final key = encrypt.Key.fromUtf8('JaNdRgUkXp2s5v8y/B?E(H+MbQeShVmY');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static decryptAES(encryptedText) {
    final key = encrypt.Key.fromUtf8('JaNdRgUkXp2s5v8y/B?E(H+MbQeShVmY');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }
}

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const ChatPage({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.userName,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  String selectedLanguageCode = "en";
  bool isEncryptionEnabled = false;
  late AnimationController _controller;

  @override
  void initState() {
    getSavedLanguage();
    getChatandAdmin();
    getEncryptionState();
    _controller = AnimationController(
      duration: const Duration(milliseconds:1000),
      vsync: this,
    );
    // _controller.repeat();
    _controller.forward();
_controller.addStatusListener((status) {
  if (status == AnimationStatus.completed) {
    Future.delayed(Duration(seconds: 4), () {
      _controller.forward(from: 0.0);
    });
  }
});

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  getChatandAdmin() {
    DatabaseServices().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseServices().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  void saveLanguage(String selectedLanguageCode) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('selectedLanguageCode', selectedLanguageCode);
  }

  void getSavedLanguage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguageCode =
          preferences.getString('selectedLanguageCode') ?? 'en';
    });
  }

  void saveEncryptionState(bool isEncryptionEnabled) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('isEncryptionEnabled', isEncryptionEnabled);
  }

  void getEncryptionState() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isEncryptionEnabled = preferences.getBool('isEncryptionEnabled') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(context, const SearchMessage());
              },
              icon: const Icon(
                Icons.search,
              )),
          languageButton(isEncryptionEnabled, context),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("🔒 Encryption"),
                    content: Text(isEncryptionEnabled
                        ? "⚠️ Do you want to disable end-to-end encryption?"
                        : "Do you want to enable end-to-end encryption? Doing so will disable the translation functionality."),
                    actions: [
                      ElevatedButton(
                        child: const Text("No"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text("Yes"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            isEncryptionEnabled = !isEncryptionEnabled;
                          });
                          saveEncryptionState(isEncryptionEnabled);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.lock,
              color: isEncryptionEnabled
                  ? Color.fromARGB(255, 43, 255, 0)
                  : Colors.white,
            ),
          ),
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                      userName: widget.userName,
                    ));
              },
              icon: const Icon(Icons.info)),
        ],
      ),
      body: Column(
        children: <Widget>[
          // chat messages here
          Expanded(child: chatMessages()), // chatMessages() calling,

          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 15),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true, //update

                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  if (isEncryptionEnabled) {
                    try {
                      return MessageTile(
                        message: Text(
                            AESEncryption.decryptAES(
                                snapshot.data.docs[index]['message']),
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index]['sender'],
                        time: snapshot.data.docs[index]['time'],
                      );
                    } catch (e) {
                      return MessageTile(
                        message: Text(snapshot.data.docs[index]['message'],
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index]['sender'],
                        time: snapshot.data.docs[index]['time'],
                      );
                    }

                    // }
                  } else {
                    if (widget.userName ==
                        snapshot.data.docs[index]['sender']) {
                      return MessageTile(
                        message: (snapshot.data.docs[index]
                                        ['isMessageEncrypted'] ==
                                    true) &&
                                (!isEncryptionEnabled)
                            ? const Text(
                                // 'You cannot view this message as it is encrypted. Turn on encryption to view it.',
                                '🔒 This message is encrypted.',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ))
                            : Text(snapshot.data.docs[index]['message'],
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16)),
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index]['sender'],
                        time: snapshot.data.docs[index]['time'],
                      );
                    } else {
                      // if (selectedLanguageCode == 'en') {
                      //   return MessageTile(
                      //     message: snapshot.data.docs[index]['message'],
                      //     sender: snapshot.data.docs[index]['sender'],
                      //     sentByMe: widget.userName ==
                      //         snapshot.data.docs[index]['sender'],
                      //     time: snapshot.data.docs[index]['time'],
                      //   );
                      // } else {
                      if (snapshot.data.docs[index]['isMessageEncrypted'] ==
                          true) {
                        return MessageTile(
                          message: const Text(
                            // 'You cannot view this message as it is encrypted. Turn on encryption to view it.',
                            '🔒 This message is encrypted.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ),
                          sender: snapshot.data.docs[index]['sender'],
                          sentByMe: widget.userName ==
                              snapshot.data.docs[index]['sender'],
                          time: snapshot.data.docs[index]['time'],
                        );
                      } else {
                        if (snapshot
                            .data
                            .docs[index]['translatedfield']
                                [selectedLanguageCode]
                            .isEmpty) {
                          return MessageTile(
                            message: const Text('Typing...',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            sender: snapshot.data.docs[index]['sender'],
                            sentByMe: widget.userName ==
                                snapshot.data.docs[index]['sender'],
                            time: snapshot.data.docs[index]['time'],
                            //get time
                          );
                        } else {
                          return MessageTile(
                            message: Text(
                                snapshot.data.docs[index]['translatedfield']
                                    [selectedLanguageCode],
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            sender: snapshot.data.docs[index]['sender'],
                            sentByMe: widget.userName ==
                                snapshot.data.docs[index]['sender'],
                            time: snapshot.data.docs[index]['time'],
                          );
                        }
                      }
                    }
                  }
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty && !isEncryptionEnabled) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "isMessageEncrypted": false,
      };

      DatabaseServices().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    } else {
      Map<String, dynamic> chatMessageMap = {
        "message": AESEncryption.encryptAES(messageController.text),
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "isMessageEncrypted": true,
      };

      DatabaseServices().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }

  Widget languageButton(bool isEncryptionEnabled, BuildContext context) {
    if (!isEncryptionEnabled) {
      return PopupMenuButton<String>(
        onSelected: (value) {
          setState(() {
            selectedLanguageCode = value;
          });
          saveLanguage(value);
        },
        icon: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
          child: const Icon(
            Icons.language,
            color: Color.fromARGB(255, 138, 231, 141),
          ),
        ),
        itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
          PopupMenuItem(
            value: "ne",
            child: Container(
              alignment: Alignment.center,
              color: selectedLanguageCode == 'ne'
                  ? Theme.of(context).primaryColor
                  : null,
              child: const Text("🇳🇵 Nepali", style: TextStyle(fontSize: 20)),
            ),
          ),
          PopupMenuItem(
            value: "en",
            child: Container(
              alignment: Alignment.center,
              color: selectedLanguageCode == 'en'
                  ? Theme.of(context).primaryColor
                  : null,
              child: const Text("🇺🇸 English", style: TextStyle(fontSize: 20)),
            ),
          ),
          PopupMenuItem(
            value: "fr",
            child: Container(
              alignment: Alignment.center,
              color: selectedLanguageCode == 'fr'
                  ? Theme.of(context).primaryColor
                  : null,
              child: const Text("🇫🇷 French", style: TextStyle(fontSize: 20)),
            ),
          ),
          PopupMenuItem(
            value: "de",
            child: Container(
              alignment: Alignment.center,
              color: selectedLanguageCode == 'de'
                  ? Theme.of(context).primaryColor
                  : null,
              child: const Text("🇩🇪 German", style: TextStyle(fontSize: 20)),
            ),
          ),
          PopupMenuItem(
            value: "zh",
            child: Container(
              alignment: Alignment.center,
              color: selectedLanguageCode == 'zh'
                  ? Theme.of(context).primaryColor
                  : null,
              child: const Text("🇨🇳 Chinese", style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      );
    } else {
      return RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
          child: IconButton(
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    content: Text(
                        "⛔ Translation is disabled because you have enabled end to end encryption!! Please turn off E2EE in order to use translation functionality."),
                  );
                },
              );
            },
          ));
    }
  }
}
