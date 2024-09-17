import 'package:flutter/material.dart';
import 'register_page.dart';
import 'custom_app_bar.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'noCloud',
        onBackPressed: () {
          // Ação para o botão de voltar
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
                // Ação para o botão de login
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Não tem uma conta? Criar aqui'),
            ),
          ],
        ),
      ),
    );
  }
}
