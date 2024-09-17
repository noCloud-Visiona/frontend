import 'package:flutter/material.dart';
import 'custom_app_bar.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'noCloud',
        onBackPressed: () {
          Navigator.pop(context);
        },
        onUserIconPressed: () {
          // Ação para o ícone de usuário
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Ação para o botão de registro
              },
              child: Text('Criar Conta'),
            ),
          ],
        ),
      ),
    );
  }
}
