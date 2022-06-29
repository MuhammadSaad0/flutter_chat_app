import 'package:flutter/material.dart';

class UserInfoDialog extends StatelessWidget {
  static const routeName = "/userinfo";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as List;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text("User Info"),
        titleSpacing: 10,
      ),
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          height: 330,
          width: 300,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image(image: NetworkImage(args[0])),
                Divider(),
                Column(
                  children: [
                    Text(
                      "Username:",
                      style: TextStyle(
                          fontSize: 22, decoration: TextDecoration.underline),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      args[1],
                      style: TextStyle(fontSize: 20, color: Colors.pink),
                    ),
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
