import 'package:flutter/material.dart';
import 'package:frontend/pages/template/app_template.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppTemplate(
      currentIndex: 0,
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}