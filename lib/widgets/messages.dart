import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bubble/bubble.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:random_string_generator/random_string_generator.dart';
import '../provider/reply_provider.dart';
import '../provider/deleting_provider.dart';

class Messages extends StatefulWidget {
  var username;
  File img;
  var roomKey;
  Messages(this.roomKey);
  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  var generator = RandomStringGenerator(
    hasAlpha: true,
    alphaCase: AlphaCase.UPPERCASE_ONLY,
    hasDigits: true,
    hasSymbols: false,
    minLength: 15,
    maxLength: 25,
    mustHaveAtLeastOneOfEach: true,
  );

  @override
  Widget build(BuildContext context) {
    final reply = Provider.of<Reply>(context, listen: false);
    final deleting = Provider.of<DeleteProvider>(context, listen: false);

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc('${widget.roomKey}')
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
        if (chatSnapshot.data == null ||
            chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = chatSnapshot.data.docs;

        return ListView.builder(
          reverse: true,
          itemBuilder: (ctx, index) => SwipeTo(
            key: ValueKey(generator.generate()),
            onRightSwipe: () {
              if (chatDocs[index]['imageUrl'] == null)
                reply.changeReply(chatDocs[index]['text']);

              if (chatDocs[index]['imageUrl'] != null)
                reply.changeReply(chatDocs[index]['imageUrl']);
            },
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onDoubleTap: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              contentPadding: EdgeInsets.all(0),
                              scrollable: true,
                              elevation: 20,
                              content: Container(
                                width: 300,
                                height: 300,
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        (chatDocs[index]['username'])
                                            .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 26,
                                            color: Colors.pink),
                                      ),
                                      Divider(),
                                      Image(
                                          image: NetworkImage(
                                              chatDocs[index]['userImage'])),
                                      Divider(),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ]),
                              ),
                            ));
                  },
                  child: InkWell(
                    onLongPress: () {
                      if (chatDocs[index]['text'] !=
                              "This message has been deleted" &&
                          chatDocs[index]['userId'] ==
                              FirebaseAuth.instance.currentUser.uid)
                        deleting.changeDeleting(true, chatDocs[index].id);
                    },
                    child: Bubble(
                      key: ValueKey(chatDocs[index].id),
                      stick: false,
                      padding: BubbleEdges.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (chatDocs[index]["replyingTo"] != "" &&
                              !chatDocs[index]["replyingTo"]
                                  .toString()
                                  .startsWith("http"))
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: chatDocs[index]['userId'] ==
                                          FirebaseAuth.instance.currentUser.uid
                                      ? Color.fromARGB(255, 170, 22, 71)
                                      : Color.fromARGB(255, 20, 95, 157),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      width: 1,
                                      color:
                                          Color.fromARGB(201, 158, 158, 158))),
                              child: Text(chatDocs[index]['replyingTo'],
                                  style: TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 0.65),
                                  )),
                            ),
                          if (chatDocs[index]['replyingTo']
                              .toString()
                              .startsWith("http"))
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    width: 4,
                                    color: chatDocs[index]['userId'] ==
                                            FirebaseAuth
                                                .instance.currentUser.uid
                                        ? Color.fromARGB(255, 146, 18, 61)
                                        : Color.fromARGB(255, 15, 74, 122),
                                  ),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Image(
                                  image: NetworkImage(
                                      chatDocs[index]['replyingTo']),
                                ),
                              ),
                            ),
                          if (chatDocs[index]['replyingTo'] != "")
                            SizedBox(
                              height: 10,
                            ),
                          if (chatDocs[index]['imageUrl'] != null)
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                      titlePadding: EdgeInsets.all(0),
                                      contentPadding: EdgeInsets.all(0),
                                      content: Stack(children: [
                                        ZoomOverlay(
                                          maxScale: 100,
                                          minScale: 0.1,
                                          twoTouchOnly: true,
                                          child: Image(
                                              image: NetworkImage(
                                                  chatDocs[index]['imageUrl'])),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(Icons.pinch),
                                          iconSize: 18,
                                        )
                                      ])),
                                );
                              },
                              child: Image(
                                frameBuilder: (context, child, frame,
                                    wasSynchronouslyLoaded) {
                                  return child;
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                                height: 200,
                                image:
                                    NetworkImage(chatDocs[index]['imageUrl']),
                              ),
                            ),
                          if (chatDocs[index]['imageUrl'] != null)
                            SizedBox(
                              height: 10,
                            ),
                          Text(
                            chatDocs[index]['username'],
                            style: TextStyle(
                                fontSize: 11,
                                color: Color.fromRGBO(255, 255, 255, 0.60)),
                            textAlign: chatDocs[index]['userId'] ==
                                    FirebaseAuth.instance.currentUser.uid
                                ? TextAlign.end
                                : TextAlign.start,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          if (chatDocs[index]['text'] != "")
                            Container(
                              width: (chatDocs[index]['imageUrl'] != null
                                  ? 165
                                  : null),
                              child: Text(
                                chatDocs[index]['text'],
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color.fromRGBO(
                                      255,
                                      255,
                                      255,
                                      chatDocs[index]['text'] ==
                                              "This message has been deleted"
                                          ? 0.7
                                          : 1),
                                  fontStyle: chatDocs[index]['text'] ==
                                          "This message has been deleted"
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                            ),
                        ],
                      ),
                      alignment: chatDocs[index]['userId'] ==
                              FirebaseAuth.instance.currentUser.uid
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      nip: chatDocs[index]['userId'] ==
                              FirebaseAuth.instance.currentUser.uid
                          ? BubbleNip.rightTop
                          : BubbleNip.leftTop,
                      color: chatDocs[index]['userId'] ==
                              FirebaseAuth.instance.currentUser.uid
                          ? Colors.pink
                          : Colors.blue,
                      margin:
                          BubbleEdges.symmetric(vertical: 14, horizontal: 5),
                      elevation: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          itemCount: chatDocs.length,
        );
      },
    );
  }
}
