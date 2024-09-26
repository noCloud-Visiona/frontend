import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/home_page.dart';
import 'register_page.dart';
import '../widgets/custom_app_navbar.dart';
import '../widgets/custom_dialog.dart';
import 'package:frontend/utils/jwt_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showCustomDialog(context, "Por favor, preencha todos os campos.", null);
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      showCustomDialog(context, "E-mail inválido.", null);
      return;
    }

    final String apiUrl = '${dotenv.env['API_URL']}/login';

    final Map<String, dynamic> loginData = {
      "email": _emailController.text,
      "senha": _passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        String token = responseBody['token']['token'];

        // Armazenando o token no AuthProvider
        Provider.of<AuthProvider>(context, listen: false).setJwtToken(token);

        // Usando seu utilitário para decodificar e imprimir informações do token
        printTokenInfo(token);

        showCustomDialog(context, "Login realizado com sucesso!", () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        });
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        showCustomDialog(context, responseBody['error'], null);
      } else {
        showCustomDialog(
            context, "Erro ao fazer login. Tente novamente.", null);
      }
    } catch (e) {
      print("Erro: $e");
      showCustomDialog(context, "Erro ao se conectar ao servidor.", null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavBar(
        onBackPressed: () {
          Navigator.pop(context);
        },
        onUserIconPressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
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
