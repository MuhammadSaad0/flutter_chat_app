import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bubble/bubble.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

class Messages extends StatefulWidget {
  var username;
  File img;
  var roomKey;
  Messages(this.roomKey);
  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
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
        if (chatSnapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = chatSnapshot.data.docs;
        return ListView.builder(
          reverse: true,
          itemBuilder: (ctx, index) => GestureDetector(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  (chatDocs[index]['username']).toString(),
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
            child: Bubble(
              key: ValueKey(chatDocs[index].id),
              stick: false,
              padding: BubbleEdges.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          return child;
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                        height: 200,
                        image: NetworkImage(chatDocs[index]['imageUrl']),
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
                      color: Color.fromRGBO(255, 255, 255, 0.75),
                    ),
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
                      width: (chatDocs[index]['imageUrl'] != null ? 165 : null),
                      child: Text(
                        chatDocs[index]['text'],
                        style: TextStyle(
                          fontSize: 18,
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
              margin: BubbleEdges.symmetric(vertical: 14, horizontal: 5),
              elevation: 10,
            ),
          ),
          itemCount: chatDocs.length,
        );
      },
    );
  }
}
