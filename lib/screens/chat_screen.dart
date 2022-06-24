import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 230, 92, 138),
        title: Text("FlutterChat"),
        actions: [
          DropdownButton(
            onChanged: (itemId) {
              if (itemId == "Logout") {
                FirebaseAuth.instance.signOut();
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
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chats/maCss0gNvWRFq7QUKJYS/messages")
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamsnapshot) {
            if (streamsnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final documents = streamsnapshot.data.docs;
            return ListView.builder(
              itemBuilder: (ctx, index) => Container(
                padding: EdgeInsets.all(8),
                child: Text(documents[index]['text']),
              ),
              itemCount: documents.length,
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          FirebaseFirestore.instance
              .collection("chats/maCss0gNvWRFq7QUKJYS/messages")
              .add({
            'text': "New Message Added!",
          });
        },
      ),
    );
  }
}
