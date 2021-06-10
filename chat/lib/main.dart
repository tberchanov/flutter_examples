import 'package:chat/screens/auth_screen.dart';
import 'package:chat/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (ctx, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : MaterialApp(
                  title: 'Flutter Chat',
                  theme: ThemeData(
                      primarySwatch: Colors.pink,
                      backgroundColor: Colors.pink,
                      accentColor: Colors.deepPurple,
                      accentColorBrightness: Brightness.dark,
                      buttonTheme: ButtonTheme.of(context).copyWith(
                        buttonColor: Colors.pink,
                        textTheme: ButtonTextTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      )),
                  home: StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (ctx, userSnapshot) {
                      if (userSnapshot.hasData) {
                        return ChatScreen();
                      } else {
                        return AuthScreen();
                      }
                    },
                  ),
                ),
    );
  }
}
