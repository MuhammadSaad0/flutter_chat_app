import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:provider/provider.dart';
import '../provider/reply_provider.dart';

class NewMessage extends StatefulWidget {
  var roomKey;
  NewMessage(this.roomKey);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = "";

  File _pickedImage;
  var generator = RandomStringGenerator(
    hasAlpha: true,
    alphaCase: AlphaCase.UPPERCASE_ONLY,
    hasDigits: true,
    hasSymbols: false,
    minLength: 15,
    maxLength: 25,
    mustHaveAtLeastOneOfEach: true,
  );
  var imagePicked = false;
  var waiting = false;
  void _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImageFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
    );
    setState(() {
      _pickedImage = File(pickedImageFile.path);
      imagePicked = true;
    });
  }

  final _controller = new TextEditingController();
  var url = null;
  void handleTimeout() {
    // callback function
    setState(() {
      waiting = false;
    });
  }

  Timer scheduleTimeout([int milliseconds = 10000]) =>
      Timer(Duration(milliseconds: milliseconds), handleTimeout);
  void _sendMessage() async {
    setState(() {
      waiting = true;
    });
    FocusScope.of(context).unfocus();
    final reply = Provider.of<Reply>(context, listen: false);
    final uId = await FirebaseAuth.instance.currentUser.uid;
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(uId).get();
    if (_pickedImage != null) {
      var msg = _enteredMessage;
      var replyinp = reply.getreply;
      final reference = await FirebaseStorage.instance
          .ref()
          .child('message_image')
          .child(generator.generate() + ".jpg");
      UploadTask uploadTask = reference.putFile(_pickedImage);
      _controller.clear();

      setState(() {
        imagePicked = false;
        _pickedImage = null;
        url = null;
      });
      uploadTask.whenComplete(() async {
        url = await reference.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('chats')
            .doc('${widget.roomKey}')
            .collection('chat')
            .add({
          'text': msg,
          'createdAt': Timestamp.now(),
          'userId': FirebaseAuth.instance.currentUser.uid,
          'username': userData['username'],
          'userImage': userData['imageUrl'],
          'imageUrl': url,
          'replyingTo': replyinp,
          'thumbsUp': 0,
          'thumbsDown': 0,
        });
      });
      setState(() {
        scheduleTimeout(5 * 1000);
        _pickedImage = null;
        url = null;
        reply.changeReply("");
      });
    } else {
      _controller.clear();
      url = null;
      await FirebaseFirestore.instance
          .collection('chats')
          .doc('${widget.roomKey}')
          .collection('chat')
          .add({
        'text': _enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': FirebaseAuth.instance.currentUser.uid,
        'username': userData['username'],
        'userImage': userData['imageUrl'],
        'imageUrl': url,
        'replyingTo': reply.getreply,
        'thumbsUp': 0,
        'thumbsDown': 0,
      });
      setState(() {
        waiting = false;
        _pickedImage = null;
        url = null;
        reply.changeReply("");
        // _enteredMessage = "";
      });
    }
    setState(() {
      _enteredMessage = "";
      //replyingTo = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final reply = Provider.of<Reply>(context);

    return Container(
      margin: reply.getreply == ""
          ? EdgeInsets.only(top: 15)
          : EdgeInsets.only(top: 40),
      padding: EdgeInsets.all(8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (reply.getreply != "" &&
              !reply.getreply.startsWith("https://firebasestorage") &&
              reply.getreply != "This message has been deleted")
            Positioned(
              left: MediaQuery.of(context).size.width / 10000,
              top: -40,
              child: Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                    border:
                        Border(left: BorderSide(width: 2, color: Colors.pink))),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    top: 9,
                  ),
                  child: Text(
                    reply.getreply,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          if (reply.getreply.startsWith("https://firebasestorage"))
            Positioned(
              left: MediaQuery.of(context).size.width / 10000,
              top: -40,
              child: Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                    border:
                        Border(left: BorderSide(width: 2, color: Colors.pink))),
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image(
                    image: NetworkImage(reply.getreply),
                  ),
                ),
              ),
            ),
          Row(children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 3, top: 1),
                child: TextField(
                  autocorrect: true,
                  enableSuggestions: true,
                  textCapitalization: TextCapitalization.sentences,
                  controller: _controller,
                  decoration: InputDecoration(labelText: "Send a message..."),
                  onChanged: (value) {
                    setState(() {
                      _enteredMessage = value;
                    });
                  },
                ),
              ),
            ),
            if (imagePicked)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Image(image: FileImage(_pickedImage)),
                    ),
                  );
                },
                child: Stack(children: [
                  ClipRRect(
                    clipBehavior: Clip.none,
                    borderRadius: BorderRadius.circular(10),
                    child: Image(
                      width: 40,
                      height: 40,
                      image: FileImage(_pickedImage),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 13,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _pickedImage = null;
                          imagePicked = false;
                        });
                      },
                      icon: Icon(
                        Icons.delete_forever_sharp,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  )
                ]),
              ),
            if (reply.getreply != "" && !waiting)
              IconButton(
                onPressed: () {
                  reply.changeReply("");
                },
                icon: Icon(
                  Icons.undo,
                  size: 20,
                ),
              ),
            IconButton(
                onPressed: waiting ? null : _pickImage,
                icon: Icon(
                  Icons.attachment,
                )),
            if (!waiting)
              IconButton(
                onPressed: _controller.text == "" && imagePicked == false
                    ? null
                    : _sendMessage,
                icon: Icon(Icons.send),
                color: Colors.pink,
              ),
            if (waiting) CircularProgressIndicator(),
          ]),
        ],
      ),
    );
  }
}
