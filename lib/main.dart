import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_complete_guide/provider/deleting_provider.dart';
import 'package:flutter_complete_guide/provider/reply_provider.dart';
import 'package:flutter_complete_guide/screens/room_selection_screen.dart';
import 'package:provider/provider.dart';
import './screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getToken();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Reply()),
        ChangeNotifierProvider(create: (context) => DeleteProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Chat',
        theme: ThemeData(
            primarySwatch: Colors.pink,
            backgroundColor: Colors.pink,
            colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: Colors.deepPurple, brightness: Brightness.dark),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
              primary: Colors.pink,
            )),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    primary: Colors.pink,
                    onPrimary: Colors.white))),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.hasData) {
              return RoomSelect();
            } else {
              return AuthScreen();
            }
          },
        ),
        routes: {
          AuthScreen.routeName: ((context) => AuthScreen()),
          RoomSelect.routeName: ((context) => RoomSelect()),
        },
      ),
    );
  }
}
