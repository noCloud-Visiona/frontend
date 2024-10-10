import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:frontend/utils/jwt_utils.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoricoPage extends StatefulWidget {
  @override
  _HistoricoPageState createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  List<dynamic> historico = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistorico();
  }

  Future<String?> _fetchJWT() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.jwtToken;

      if (token != null && isTokenValid(token)) {
        return token;
      } else {
        throw Exception("Token inválido ou inexistente.");
      }
    } catch (error) {
      print('Erro ao buscar o JWT: $error');
      return null;
    }
  }

  Future<void> _fetchHistorico() async {
    try {
      final token = await _fetchJWT();
      if (token != null) {
        final decodedToken = getDecodedToken(token);
        final userId = decodedToken?['id'];

        if (userId != null) {
          final response = await http.get(
            Uri.parse('${dotenv.env['AI_API_URL']}/historico/$userId'),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            setState(() {
              historico = data;
              isLoading = false;
            });
          } else {
            throw Exception('Falha ao carregar histórico.');
          }
        } else {
          print('Erro: ID do usuário não encontrado.');
        }
      }
    } catch (error) {
      print('Erro ao carregar histórico: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteImage(String? imageId) async {
    if (imageId == null) {
      print('Erro: ID da imagem é null.');
      return;
    }

    try {
      final token = await _fetchJWT();
      if (token != null) {
        final decodedToken = getDecodedToken(token);
        final userId = decodedToken?['id'];

        if (userId != null) {
          final response = await http.delete(
            Uri.parse('${dotenv.env['AI_API_URL']}/delete_image/$imageId/$userId'),
          );

          if (response.statusCode == 200) {
            setState(() {
              historico.removeWhere((item) => item['id_imagem'] == imageId);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Imagem deletada com sucesso!')),
            );
          } else {
            throw Exception('Falha ao deletar imagem.');
          }
        } else {
          print('Erro: ID do usuário não encontrado.');
        }
      }
    } catch (error) {
      print('Erro ao deletar imagem: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar imagem.')),
      );
    }
  }

  void  _confirmDelete(String? imageId) {
    if (imageId == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Você realmente deseja excluir esta imagem?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o popup
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o popup
                _deleteImage(imageId); // Chama a função para deletar a imagem
              },
              child: Text('Deletar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Imagens'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : historico.isEmpty
              ? Center(child: Text('Sem histórico de imagem disponível no momento.'))
              : ListView.builder(
                  itemCount: historico.length,
                  itemBuilder: (context, index) {
                    final item = historico[index];
                    final imageId = item['id_imagem'] as String?;

                    return ListTile(
                      leading: Image.network(
                        Uri.encodeFull(item['thumbnail'] ?? 'https://via.placeholder.com/640'),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 50,
                          );
                        },
                      ),
                      title: Text('Satelite: ${item['satelite']}'),
                      subtitle: Text('Data: ${item['data']} - Hora: ${item['hora']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Área Visível: ${item['area_visivel_mapa']}%'),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmDelete(imageId);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Ação ao clicar no item da lista
                      },
                    );
                  },
                ),
    );
  }
}
