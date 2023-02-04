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

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  String selectedLanguageCode = "en";
  bool isEncrypted = false;

  @override
  void initState() {
    getSavedLanguage();
    getChatandAdmin();
     getEncryptionState();
    super.initState();
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

  void saveEncryptionState(bool isEncrypted) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('isEncrypted', isEncrypted);
  }

void getEncryptionState() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  setState(() {
    isEncrypted = preferences.getBool('isEncrypted') ?? false;
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
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedLanguageCode = value;
              });
              saveLanguage(value);
            },
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              PopupMenuItem(
                value: "ne",
                child: Container(
                  color: selectedLanguageCode == 'ne'
                      ? Theme.of(context).primaryColor
                      : null,
                  child: const Text("Nepali"),
                ),
              ),
              PopupMenuItem(
                value: "en",
                child: Container(
                  color: selectedLanguageCode == 'en'
                      ? Theme.of(context).primaryColor
                      : null,
                  child: const Text("English"),
                ),
              ),
              PopupMenuItem(
                value: "fr",
                child: Container(
                  color: selectedLanguageCode == 'fr'
                      ? Theme.of(context).primaryColor
                      : null,
                  child: const Text("French"),
                ),
              ),
              PopupMenuItem(
                value: "de",
                child: Container(
                  color: selectedLanguageCode == 'de'
                      ? Theme.of(context).primaryColor
                      : null,
                  child: const Text("German"),
                ),
              ),
              PopupMenuItem(
                value: "zh",
                child: Container(
                  color: selectedLanguageCode == 'zh'
                      ? Theme.of(context).primaryColor
                      : null,
                  child: const Text("Chinese"),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("🔒 Encryption"),
                    content: Text(isEncrypted
                        ? "⚠️ Do you want to disable end-to-end encryption?"
                        : "Do you want to enable end-to-end encryption? Doing so will disable the translation functionality."),
                    actions: [
                      ElevatedButton(
                        child: const Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text("Yes"),
                        onPressed: () {
                          setState(() {
                            isEncrypted = !isEncrypted;
                          });
                          saveEncryptionState(isEncrypted);
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
              color: isEncrypted ? Color.fromARGB(255, 43, 255, 0) : null,
            ),
          ),
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
                    child: const Center(
                        child: Icon(
                      Icons.send,
                      color: Colors.white,
                    )),
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
                  if (isEncrypted) {
                    try {
                      return MessageTile(
                        message: AESEncryption.decryptAES(
                            snapshot.data.docs[index]['message']),
                        sender: snapshot.data.docs[index]['sender'],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index]['sender'],
                        time: snapshot.data.docs[index]['time'],
                      );
                    } catch (e) {
                      return MessageTile(
                        message: snapshot.data.docs[index]['message'],
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
                        message: snapshot.data.docs[index]['message'],
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
                      if (snapshot
                          .data
                          .docs[index]['translatedfield'][selectedLanguageCode]
                          .isEmpty) {
                        return MessageTile(
                          message: "Typing....",
                          sender: snapshot.data.docs[index]['sender'],
                          sentByMe: widget.userName ==
                              snapshot.data.docs[index]['sender'],
                          time: snapshot.data.docs[index]['time'],
                          //get time
                        );
                      } else {
                        return MessageTile(
                          message: snapshot.data.docs[index]['translatedfield']
                              [selectedLanguageCode],
                          sender: snapshot.data.docs[index]['sender'],
                          sentByMe: widget.userName ==
                              snapshot.data.docs[index]['sender'],
                          time: snapshot.data.docs[index]['time'],
                        );
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
    if (messageController.text.isNotEmpty && !isEncrypted) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        // "message": AESEncryption.encryptAES(messageController.text),

        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
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
      };

      DatabaseServices().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
