import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tfc_industria/login.dart'; // Garanta que esse caminho esteja correto
import 'package:firebase_core/firebase_core.dart';
import 'package:tfc_industria/navigationBarPages/base.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        databaseURL: "https://flutter-firebase-tfc-e46ac-default-rtdb.europe-west1.firebasedatabase.app",
    apiKey: 'AIzaSyABPtBXhd8RwisgvTsnyl3c8GlJqSKnqfs',
    appId: '1:835094502343:android:a7e413ab1467d4b8d357e2',
    messagingSenderId: '835094502343',
    projectId: 'flutter-firebase-tfc-e46ac',
    storageBucket: 'flutter-firebase-tfc-e46ac.appspot.com',
  ));


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home:
          Login(), // Certifique-se de que 'Login' é o widget correto para a tela inicial
    );
  }
}
