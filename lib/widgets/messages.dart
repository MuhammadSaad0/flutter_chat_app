import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bubble/bubble.dart';

class Messages extends StatelessWidget {
  const Messages({Key key}) : super(key: key);

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
            child: Text(
              chatDocs[index]['text'],
              style: TextStyle(fontSize: 18),
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
            margin: BubbleEdges.symmetric(vertical: 12, horizontal: 5),
            elevation: 10,
          ),
          itemCount: chatDocs.length,
        );
      },
    );
  }
}
