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

  Future<void> _fetchHistorico() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.jwtToken;

      if (token != null && isTokenValid(token)) {
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
        }
      }
    } catch (error) {
      print('Erro ao carregar histórico: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Imagens'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: historico.length,
              itemBuilder: (context, index) {
                final item = historico[index];
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
                  trailing: Text('Área Visível: ${item['area_visivel_mapa']}%'),
                  onTap: () {
                    // Ação ao clicar no item da lista
                  },
                );
              },
            ),
    );
  }
}
