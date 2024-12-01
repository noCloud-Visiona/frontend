import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart'; // Certifique-se de que o caminho está correto
import 'package:frontend/utils/jwt_utils.dart'; // Certifique-se de que o caminho está correto
import 'package:frontend/pages/detalhe_imagem_INPE_page.dart';
import 'package:intl/intl.dart'; // Importando a biblioteca intl para formatação de data

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> _historico = [];

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
        print('userId: $userId');

        if (userId != null) {
          final response = await http.get(
            Uri.parse('${dotenv.env['FIREBASE_API_URL']}/historico/$userId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            setState(() {
              _historico = data;
            });
          } else {
            print('Erro ao buscar histórico: ${response.statusCode}');
          }
        }
      }
    } catch (error) {
      print('Erro ao buscar histórico: $error');
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Desconhecido';
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return 'Desconhecido';
    }
  }

  void _confirmDelete(String imageId, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir esta imagem?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteImage(imageId, userId);
                Navigator.of(context).pop();
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteImage(String imageId, String userId) async {
    try {
      final token = await _fetchJWT();
      if (token != null) {
        final response = await http.delete(
          Uri.parse('${dotenv.env['FIREBASE_API_URL']}/delete_image/$imageId/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            _historico.removeWhere((item) => item['id'] == imageId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imagem excluída com sucesso.')),
          );
        } else {
          print('Erro ao excluir imagem: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Erro ao excluir imagem: $error');
    }
  }

  Future<void> _fetchStatus(String jobId) async {
    try {
      final token = await _fetchJWT();
      if (token != null) {
        final response = await http.get(
          Uri.parse('${dotenv.env['FIREBASE_API_URL']}/status/$jobId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalheImgINPEPage(
                data: data,
                imageBytes: null, // Passe os bytes da imagem se necessário
              ),
            ),
          );
        } else {
          print('Erro ao buscar status: ${response.statusCode}');
        }
      }
    } catch (error) {
      print('Erro ao buscar status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico'),
      ),
      body: _historico.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _historico.length,
              itemBuilder: (context, index) {
                final item = _historico[index];
                final jobId = item['jobId'] ?? 'Desconhecido';
                final imageId = item['id'] ?? 'Desconhecido';
                final userId = item['userId'] ?? 'Desconhecido'; // Certifique-se de que o userId está presente no item
                return ListTile(
                  leading: item['identificacao_ia'] != null && item['identificacao_ia']['thumbnail_imagem_url'] != null
                      ? Image.network(
                          item['identificacao_ia']['thumbnail_imagem_url'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image_not_supported),
                  title: Text('Satelite: ${item['collection'] ?? 'Desconhecido'}'),
                  subtitle: Text('Data: ${_formatDate(item['data'])} - Hora: ${item['hora'] ?? 'Desconhecido'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Área Visível: ${item['identificacao_ia'] != null ? item['identificacao_ia']['area_visivel_mapa'] ?? '0' : '0'}%'),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDelete(imageId, userId);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    if (jobId != 'Desconhecido') {
                      _fetchStatus(jobId); // Buscar status e redirecionar
                    } else {
                      print('Job ID não encontrado.');
                    }
                  },
                );
              },
            ),
    );
  }
}