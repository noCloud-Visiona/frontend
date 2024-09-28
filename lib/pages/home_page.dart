import 'package:flutter/material.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception('userId não encontrado em SharedPreferences');
    }
    return userId;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        } else {
          final userId = snapshot.data!;
          return AppTemplate(
            currentIndex: 0,
            body: Center(
              child: Text('Bem-vindo, usuário $userId'),
            ),
          );
        }
      },
    );
  }
}