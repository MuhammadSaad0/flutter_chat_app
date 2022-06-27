import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/messages.dart';
import '../widgets/new_message.dart';

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
      body: Container(
        child: Column(children: [
          Expanded(child: Messages()),
          NewMessage(),
        ]),
      ),
    );
  }
}
