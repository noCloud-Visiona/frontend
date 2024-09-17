import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'noCloud',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          titleLarge: TextStyle(color: Colors.white), // Atualizado para 'titleLarge'
        ),
      ),
      home: LoginPage(),
    );
  }
}
