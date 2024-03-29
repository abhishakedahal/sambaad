import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sambaad/pages/group_info.dart';
import 'package:sambaad/services/database_services.dart';
import 'package:sambaad/widgets/message_tile.dart';
import 'package:sambaad/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambaad/algorithm/aes/lib/encrypt.dart' as encrypt;

class AESEncryption {
  static encryptAES(plainText) {
    final key = encrypt.Key.fromUtf8('JaNdRgUkXp2s5v8y');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static decryptAES(encryptedText) {
    final key = encrypt.Key.fromUtf8('JaNdRgUkXp2s5v8y');
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
  bool isProfanityFilterEnabled = false;
  String messageText =
      "🔞This message contains potentially offensive content. Disable profanity filter to view it 🔞";
  late AnimationController _controller;

  @override
  void initState() {
    getSavedLanguage();
    getChatandAdmin();
    getProfanityFilterState();
    getEncryptionState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

  void saveProfanityFilterState(bool isProfanityFilterEnabled) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('isProfanityFilterEnabled', isProfanityFilterEnabled);
  }

  void getProfanityFilterState() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isProfanityFilterEnabled =
          preferences.getBool('isProfanityFilterEnabled') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: Text(
          widget.groupName,
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        backgroundColor: Color(0xFF3A98B9),
        toolbarHeight: 60,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Profanity Filter"),
                    content: Text(isProfanityFilterEnabled
                        ? "⚠️ Do you want to disable profanity filter?"
                        : "Do you want to enable profanity filter? Note that this will not work with encryption enabled."),
                    actions: [
                      ElevatedButton(
                        child: const Text("No"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 112, 112, 112),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text("Yes"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3A98B9),
                        ),
                        onPressed: () {
                          setState(() {
                            isProfanityFilterEnabled =
                                !isProfanityFilterEnabled;
                          });
                          saveProfanityFilterState(isProfanityFilterEnabled);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.generating_tokens_outlined,
              color: isProfanityFilterEnabled
                  ? Color.fromARGB(255, 43, 255, 0)
                  : Colors.white,
            ),
          ),
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
                        : "Enabling end-to-end encryption will disable the translation functionality."),
                    actions: [
                      ElevatedButton(
                        child: const Text("No"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 112, 112, 112),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text("Yes"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3A98B9),
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
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Color(0xFF3A98B9),
            ),
            height: 55,
            width: 400,
            child: Row(children: [
              Expanded(
                  child: TextFormField(
                controller: messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  hintStyle: TextStyle(color: Colors.white, fontSize: 15),
                  border: InputBorder.none,
                ),
                onFieldSubmitted: (value) {
                  sendMessage();
                },
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
                  width: 55,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Center(
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                      child: const Icon(
                        Icons.send,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                ),
              )
            ]),
          ),
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
                          if (isProfanityFilterEnabled) {
                            if (snapshot.data.docs[index]['attribute_scores']
                                    ['PROFANITY'] ==
                                null) {
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
                            } else if (snapshot.data.docs[index]
                                        ['attribute_scores']['PROFANITY'] !=
                                    null &&
                                snapshot.data.docs[index]['attribute_scores']
                                        ['PROFANITY'] >
                                    0.6) {
                              return MessageTile(
                                message: GestureDetector(
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm'),
                                          content: const Text(
                                              '⚠️ Are you sure you want to view this message?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();

                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Center(
                                                      child:
                                                          SingleChildScrollView(
                                                        child: AlertDialog(
                                                          title: Text(
                                                            'Message from ${snapshot.data.docs[index]['sender']}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          content: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                snapshot.data.docs[
                                                                            index]
                                                                        [
                                                                        'translatedfield']
                                                                    [
                                                                    selectedLanguageCode],
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              Text(
                                                                'Sent at: ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.docs[index]['time']))}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'OK'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Text('Yes'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('No'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    messageText,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
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
                                      snapshot.data.docs[index]
                                              ['translatedfield']
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
                    }
                  }
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.trim().isNotEmpty && !isEncryptionEnabled) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text.trim(),
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
        "message": AESEncryption.encryptAES(messageController.text.trim()),
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
            color: Color.fromARGB(255, 39, 231, 55),
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
