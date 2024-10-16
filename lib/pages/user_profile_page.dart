import 'package:flutter/material.dart';
import 'package:frontend/pages/list_user_page.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/jwt_utils.dart';
import 'package:frontend/widgets/custom_dialog.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = true;
  Map<String, dynamic>? userData;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? token = authProvider.jwtToken;

      if (token != null && isTokenValid(token)) {
        Map<String, dynamic>? decodedToken = getDecodedToken(token);
        if (decodedToken != null) {
          int userId = decodedToken['id'];
          _isAdmin = decodedToken['is_adm'] == true;

          final String apiUrl = '${dotenv.env['API_URL']}/usuarios/$userId';
          final response = await http.get(
            Uri.parse(apiUrl),
            headers: {
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode == 200) {
            setState(() {
              userData = jsonDecode(response.body);
              _nameController.text = userData!['nome'];
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
    }
  }

  Future<void> _updateUserInfo() async {
    try {
      if (_nameController.text.isEmpty) {
        _showCustomDialog("O nome não pode estar vazio.");
        return;
      }

      if (_passwordController.text.isNotEmpty &&
          _passwordController.text != _confirmPasswordController.text) {
        _showCustomDialog("As senhas não conferem.");
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? token = authProvider.jwtToken;
      if (token != null && isTokenValid(token)) {
        final String apiUrl = '${dotenv.env['API_URL']}/usuarios/atualizar';

        final response = await http.put(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'novoNome': _nameController.text,
            'novaSenha': _passwordController.text.isEmpty
                ? null
                : _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          _showCustomDialog("Informações do usuário atualizadas com sucesso!");
        } else {
          _showCustomDialog("Erro ao atualizar as informações: ${response.body}");
        }
      }
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      _showCustomDialog("Erro inesperado ao atualizar usuário.");
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _showCustomDialog(String message, [VoidCallback? onOkPressed]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Atenção',
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onOkPressed != null) {
                  onOkPressed();
                }
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Minha Conta')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Conta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _passwordController,
              decoration:
                  const InputDecoration(labelText: 'Nova Senha (opcional)'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration:
                  const InputDecoration(labelText: 'Confirme a Nova Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserInfo,
              child: const Text('Atualizar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ListUsersPage(),
                  ),
                );
              },
              child: const Icon(Icons.list),
              tooltip: 'Listar Todos Usuários',
            )
          : null,
    );
  }
}
