import 'package:flutter/material.dart';
import 'package:frontend/pages/home_page.dart';
import 'register_page.dart';
import '../widgets/custom_app_navbar.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavBar(
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
            const TextField(
              decoration: InputDecoration(labelText: 'E-mail'),
            ),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Ação para o botão de login
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text('Não tem uma conta? Criar aqui'),
            ),
          ],
        ),
      ),
    );
  }
}