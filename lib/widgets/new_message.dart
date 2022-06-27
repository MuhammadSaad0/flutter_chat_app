import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key key}) : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = "";
  final _controller = new TextEditingController();
  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final uId = await FirebaseAuth.instance.currentUser.uid;
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(uId).get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': FirebaseAuth.instance.currentUser.uid,
      'username': userData['username'],
    });
    _controller.clear();
    _enteredMessage = "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Send a message..."),
            onChanged: (value) {
              setState(() {
                _enteredMessage = value;
              });
            },
          ),
        ),
        IconButton(
          onPressed: _controller.text == "" ? null : _sendMessage,
          icon: Icon(Icons.send),
          color: Colors.pink,
        )
      ]),
    );
  }
}
