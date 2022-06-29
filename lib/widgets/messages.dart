import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bubble/bubble.dart';

class Messages extends StatefulWidget {
  const Messages({Key key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
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
          itemBuilder: (ctx, index) => Bubble(
            key: ValueKey(chatDocs[index].id),
            stick: false,
            padding: BubbleEdges.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (chatDocs[index]['imageUrl'] != null)
                  Image(
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
          // Positioned(
          //     top: -10,
          //     left: chatDocs[index]['userId'] ==
          //             FirebaseAuth.instance.currentUser.uid
          //         ? MediaQuery.of(context).size.width /
          //             (MediaQuery.of(context).orientation ==
          //                     Orientation.landscape
          //                 ? 1.05
          //                 : 1.1)
          //         : null,
          //     right: chatDocs[index]['userId'] ==
          //             FirebaseAuth.instance.currentUser.uid
          //         ? null
          //         : MediaQuery.of(context).size.width /
          //             (MediaQuery.of(context).orientation ==
          //                     Orientation.landscape
          //                 ? 1.05
          //                 : 1.1),
          //     child: CircleAvatar(
          //       maxRadius: 15,
          //       backgroundImage: NetworkImage(chatDocs[index]['userImage']),
          //     )),

          itemCount: chatDocs.length,
        );
      },
    );
  }
}
