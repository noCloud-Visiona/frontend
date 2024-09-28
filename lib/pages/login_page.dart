import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importando SharedPreferences
import 'package:frontend/pages/home_page.dart';
import 'register_page.dart';
import '../widgets/custom_app_navbar.dart';
import '../widgets/custom_dialog.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Importando jwt_decoder

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    // Verificando se os campos estão preenchidos
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog("Por favor, preencha todos os campos.");
      return;
    }

    // Validando o e-mail com regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showErrorDialog("E-mail inválido.");
      return;
    }

    // Lógica de login
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'senha': _passwordController.text, // Certifique-se de que o campo é 'senha' e não 'password'
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('token') && data['token'].containsKey('token')) {
          final token = data['token']['token'];
          final decodedToken = JwtDecoder.decode(token);
          final userId = decodedToken['id'].toString(); // Extraindo userId do token

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('userId', userId);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          _showErrorDialog("Resposta inesperada do servidor.");
        }
      } else {
        final responseBody = jsonDecode(response.body);
        _showErrorDialog(responseBody['mensagem'] ?? "Falha no login. Verifique suas credenciais.");
      }
    } catch (e) {
      print("Erro: $e");
      _showErrorDialog("Erro ao conectar ao servidor. Tente novamente mais tarde.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Erro',
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Roboto',
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(2, 2),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF009D42),
              ),
              child: const Text(
                "Ok",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(2, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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