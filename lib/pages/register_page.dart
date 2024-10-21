import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_page.dart';
import '../widgets/custom_app_navbar.dart';
import '../widgets/custom_dialog.dart'; // Importe o arquivo do dialog aqui

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    // Verificando se todos os campos estão preenchidos
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorDialog("Por favor, preencha todos os campos.");
      return;
    }

    // Validando o e-mail com regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showErrorDialog("E-mail inválido.");
      return;
    }

    final String apiUrl = '${dotenv.env['API_URL']}/usuarios';

    final Map<String, dynamic> userData = {
      "nome": _nameController.text,
      "email": _emailController.text,
      "senha": _passwordController.text
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog("Usuário cadastrado com sucesso!");
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['message'] == "E-mail já cadastrado") {
          _showErrorDialog("E-mail já cadastrado.");
        } else {
          _showErrorDialog("Erro do servidor. Tente novamente.");
        }
      } else {
        _showErrorDialog("Erro do servidor. Tente novamente.");
      }
    } catch (e) {
      print("Erro: $e");
      _showErrorDialog("Erro ao se conectar ao servidor.");
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Sucesso',
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
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
        shouldCheckJwt: false
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
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
              onPressed: _register,
              child: const Text('Criar Conta'),
            ),
          ],
        ),
      ),
    );
  }
}