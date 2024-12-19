import 'package:flutter/material.dart';
import 'package:tfc_industria/loginuser.dart'; // Certifique-se de que o caminho esteja correto

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Indústria',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LoginUser(), // Define LoginUser como a tela inicial
    );
  }
}
