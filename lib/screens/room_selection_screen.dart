import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomSelect extends StatefulWidget {
  const RoomSelect({Key key}) : super(key: key);
  static const routeName = "/roomscreen";

  @override
  State<RoomSelect> createState() => _RoomSelectState();
}

class _RoomSelectState extends State<RoomSelect> {
  var createRoomKey;
  var joinRoomKey;
  final _formKey = GlobalKey<FormState>();

  void _trySubmit() async {
    final formValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (formValid) {
      _formKey.currentState.save();
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(createRoomKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Card(
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter a valid key";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          createRoomKey = value;
                        },
                        decoration: InputDecoration(
                            label: Text(
                              "Enter key",
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 0.3)),
                            ),
                            contentPadding: EdgeInsets.all(10),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.pink))),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: _trySubmit,
                        child: Text(
                          "Create/Join Room",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.pink,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextButton.icon(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                          },
                          icon: Icon(Icons.logout),
                          label: Text("Logout")),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  )),
            ),
          ),
        ));
  }
}
