import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/widgets/custom_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/utils/jwt_utils.dart';

class ListUsersPage extends StatefulWidget {
  const ListUsersPage({super.key});

  @override
  _ListUsersPageState createState() => _ListUsersPageState();
}

class _ListUsersPageState extends State<ListUsersPage> {
  List<dynamic>? users;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? token = authProvider.jwtToken;
      if (token != null && isTokenValid(token)) {
        final String apiUrl = '${dotenv.env['API_URL']}/usuarios/listar';

        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            users = jsonDecode(response.body);
          });
        } else {
          showCustomDialog(context, "Erro ao listar usuários: ${response.body}", null);
        }
      }
    } catch (e) {
      print('Erro ao buscar usuários: $e');
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? token = authProvider.jwtToken;
      if (token != null && isTokenValid(token)) {
        final String apiUrl = '${dotenv.env['API_URL']}/usuarios/delete';

        final response = await http.delete(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'id_usuario': userId, // Enviando o id_usuario no corpo da requisição
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            users!.removeWhere((user) => user['id_usuario'] == userId);
          });
          showCustomDialog(context, "Usuário deletado com sucesso!", null);
        } else {
          showCustomDialog(context, "Erro ao deletar usuário: ${response.body}", null);
        }
      }
    } catch (e) {
      print('Erro ao deletar usuário: $e');
    }
  }

  Future<void> _makeUserPremium(int userId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final String? token = authProvider.jwtToken;
      if (token != null && isTokenValid(token)) {
        final String apiUrl = '${dotenv.env['API_URL']}/usuarios/tornarPremium';

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'id_usuario': userId, // Enviando o id_usuario no corpo da requisição
          }),
        );

        if (response.statusCode == 200) {
          showCustomDialog(context, "Usuário agora é premium!", null);
          setState(() {
            final userIndex = users!.indexWhere((user) => user['id_usuario'] == userId);
            if (userIndex != -1) {
              users![userIndex]['is_premium'] = true;
            }
          });
        } else {
          showCustomDialog(context, "Erro ao tornar usuário premium: ${response.body}", null);
        }
      }
    } catch (e) {
      print('Erro ao tornar usuário premium: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Usuários')),
      body: users == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users!.length,
              itemBuilder: (context, index) {
                final user = users![index];
                return ListTile(
                  title: Text(user['nome']),
                  subtitle: Text(user['email']),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == 'delete') {
                        _deleteUser(user['id_usuario']);
                      } else if (value == 'premium') {
                        _makeUserPremium(user['id_usuario']);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'premium',
                        child: Text('Tornar Premium'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Deletar Usuário'),
                      ),
                    ],
                  ),
                  leading: user['is_premium'] == true
                      ? const Icon(Icons.star, color: Colors.amber)
                      : null,
                );
              },
            ),
    );
  }
}
