import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_complete_guide/provider/deleting_provider.dart';
import 'package:flutter_complete_guide/screens/auth_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../widgets/messages.dart';
import '../widgets/new_message.dart';
import '../provider/deleting_provider.dart';

class ChatScreen extends StatefulWidget {
  var roomKey;
  ChatScreen(this.roomKey);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message.notification.title);
    });
    FirebaseMessaging.onBackgroundMessage((message) {
      print(message.notification.title);
      return Future.delayed(Duration.zero);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Isdeleting = Provider.of<DeleteProvider>(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 230, 92, 138),
          title: Text("FlutterChat"),
          actions: [
            if (Isdeleting.getDeleting == true)
              IconButton(
                  enableFeedback: true,
                  splashColor: Color.fromRGBO(255, 255, 255, 0.4),
                  splashRadius: 400,
                  onPressed: () async {
                    var shouldDelete;
                    await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text("Are you sure you want to delete?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        shouldDelete = false;
                                      });

                                      Navigator.of(context).pop();
                                    },
                                    child: Text("No")),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        shouldDelete = true;
                                      });

                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Yes")),
                              ],
                            ));
                    if (shouldDelete == true)
                      FirebaseFirestore.instance
                          .collection('chats')
                          .doc('${widget.roomKey}')
                          .collection('chat')
                          .doc(Isdeleting.getChatDocIndex)
                          .update({
                        'text': 'This message has been deleted',
                        'replyingTo': "",
                        'imageUrl': null,
                      });
                    Isdeleting.changeDeleting(false, "");
                    shouldDelete = false;
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.white,
                  )),
            if (Isdeleting.getDeleting == true)
              IconButton(
                  enableFeedback: true,
                  splashColor: Color.fromRGBO(255, 255, 255, 0.4),
                  splashRadius: 400,
                  onPressed: () {
                    Isdeleting.changeDeleting(false, "");
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  )),
            if (Isdeleting.getDeleting != true)
              DropdownButton(
                underline: Container(),
                onChanged: (itemId) {
                  if (itemId == "Logout") {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(
                        context, AuthScreen.routeName);
                  }
                },
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                dropdownColor: Colors.white,
                items: [
                  DropdownMenuItem(
                    child: Container(
                      child: Row(children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Log out",
                          style: TextStyle(color: Colors.black),
                        ),
                      ]),
                    ),
                    value: "Logout",
                  )
                ],
              ),
          ]),
      body: Container(
        child: Column(children: [
          Expanded(child: Messages(widget.roomKey)),
          NewMessage(widget.roomKey),
        ]),
      ),
    );
  }
}
