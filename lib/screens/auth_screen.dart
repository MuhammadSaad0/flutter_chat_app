import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_complete_guide/screens/room_selection_screen.dart';
import '../widgets/auth_form.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key key}) : super(key: key);
  static const routeName = "/authscreen";

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
        Navigator.of(context).pushReplacementNamed(RoomSelect.routeName);
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
          await FirebaseFirestore.instance
              .collection("users")
              .doc(authResult.user.uid)
              .set({
            'username': username,
            'email': email,
            'imageUrl': url,
          });
        });
        Navigator.of(context).popAndPushNamed(RoomSelect.routeName);
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
    await DefaultCacheManager().emptyCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm),
    );
  }
}
