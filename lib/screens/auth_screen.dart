import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var url;
  void _submitAuthForm(String email, String username, String password,
      bool isLogin, BuildContext ctx, File image) async {
    UserCredential authResult;
    try {
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        final reference = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(authResult.user.uid + ".jpg");
        UploadTask uploadTask = reference.putFile(image);
        uploadTask.whenComplete(() async {
          url = await reference.getDownloadURL();
          FirebaseFirestore.instance
              .collection("users")
              .doc(authResult.user.uid)
              .set({
            'username': username,
            'email': email,
            'imageUrl': url,
          });
        });
      }
    } on FirebaseAuthException catch (error) {
      var message = "An error occurred. Please check your credentials";
      if (error.message != null) {
        message = error.message;
      }
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.pink,
        ),
      );
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm),
    );
  }
}
