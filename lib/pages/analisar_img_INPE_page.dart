import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/pages/detalhe_imagem_INPE_page.dart';
import 'package:frontend/pages/visualizar_img_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalisarImgINPEpage extends StatefulWidget {
  final String id;
  final String thumbnailUrl;
  final String datetime;
  final double north;
  final double south;
  final double east;
  final double west;
  final Map<String, dynamic> featureData;

  const AnalisarImgINPEpage({
    Key? key,
    required this.id,
    required this.thumbnailUrl,
    required this.datetime,
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    required this.featureData,
  }) : super(key: key);

  @override
  _AnalisarImgINPEpageState createState() => _AnalisarImgINPEpageState();
}

class _AnalisarImgINPEpageState extends State<AnalisarImgINPEpage> {
  Future<void> _analisarImagem(BuildContext context) async {
    try {
      // Criar o JSON com os dados da imagem e as coordenadas do usuário
      var requestData = {
        "type": widget.featureData["type"],
        "id": widget.featureData["id"],
        "collection": widget.featureData["collection"],
        "stac_version": widget.featureData["stac_version"],
        "stac_extensions": widget.featureData["stac_extensions"],
        "geometry": widget.featureData["geometry"],
        "links": widget.featureData["links"],
        "bbox": widget.featureData["bbox"],
        "assets": widget.featureData["assets"],
        "thumbnail": widget.featureData["thumbnail"],
        "properties": widget.featureData["properties"],
        "user_geometry": {
          "type": "Polygon",
          "coordinates": [
            [
              [widget.west, widget.south],
              [widget.west, widget.north],
              [widget.east, widget.north],
              [widget.east, widget.south],
              [widget.west, widget.south]
            ]
          ]
        }
      };

      // Obter o ID do usuário
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception('userId não encontrado em SharedPreferences');
      }

      // Definir a URL da API
      var apiUrl = dotenv.env['AI_API_URL'];
      var uri = Uri.parse('$apiUrl/predict/$userId');

      // Fazer o POST com o JSON
      var response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestData),
      );

      // Verificar a resposta
      if (response.statusCode == 202) {
        Navigator.pop(context); // Fecha o diálogo de carregamento
        print(response);

        // Converte o corpo da resposta para um mapa
        var responseBody = json.decode(response.body); // Decodifica o corpo da resposta em um Map

        // Agora você pode acessar job_id dentro do mapa decodificado
        var jobId = responseBody['job_id']; // Acessa o job_id do mapa decodificado

        // Exibe o popup com a mensagem de que a análise está em andamento
        _showAnalysisInProgressDialog(context, userId, jobId);
      } else {
        throw Exception('Falha ao analisar imagem. Código: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Processando imagem...'),
            ],
          ),
        );
      },
    );
  }

  void _showAnalysisInProgressDialog(BuildContext context, String userId, String jobId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Análise em andamento'),
          content: const Text(
              'A análise está em andamento!\nVerifique a análise no seu histórico em aproximadamente 10 minutos.\nOu espere e clique em "Verificar análise".'),
          actions: [
            TextButton(
              onPressed: () async {
                // Verificar o status da análise
                var statusResponse = await _verificarStatusAnalise(context, userId, jobId);

                if (statusResponse != null && statusResponse['result'] != null) {
                  Navigator.of(context).pop(); // Fecha o diálogo de análise em andamento

                  // Navegar para a página de detalhes da imagem
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalheImgINPEPage(
                        data: statusResponse['result'],
                        imageBytes: statusResponse['image_bytes'], // Ajuste conforme necessário
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('A análise ainda não foi concluída. Tente novamente mais tarde.')),
                  );
                }
              },
              child: const Text('Verificar análise'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _verificarStatusAnalise(BuildContext context, String userId, String jobId) async {
    try {
      // Fazer o GET para verificar o status da análise
      var apiUrl = dotenv.env['AI_API_URL'];
      var uri = Uri.parse('$apiUrl/status/$userId/$jobId');

      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        } else {
          throw Exception('Formato de resposta inesperado');
        }
      } else {
        throw Exception('Falha ao verificar o status da análise. Código: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar status: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double imageHeight = screenHeight * 0.40;

    double screenWidth = MediaQuery.of(context).size.width;
    double imageWidth = screenWidth * 0.20;

    return AppTemplate(
      currentIndex: 1,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${widget.id}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 2),
            Center(
              child: Text('NORTE: ${widget.north.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 16)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('OESTE: ${widget.west.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 16)),
                Text('LESTE: ${widget.east.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            Center(
              child: Text('SUL: ${widget.south.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 16)),
            ),
            const Divider(thickness: 2),
            Text('Data: ${widget.datetime}', style: const TextStyle(fontSize: 16)),
            const Divider(thickness: 2),
            Center(
              child: Column(
                children: [
                  if (kIsWeb)
                    Image.network(
                      widget.thumbnailUrl,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.cover,
                    )
                  else
                    Image.network(
                      widget.thumbnailUrl,
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showLoadingDialog(context);
                      _analisarImagem(context);
                    },
                    child: const Text('Analisar'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisualizarImagemPage(
                            featureData: widget.featureData,
                            north: widget.north,
                            south: widget.south,
                            east: widget.east,
                            west: widget.west,
                            id: '',
                            thumbnailUrl: '',
                            datetime: '',
                          ),
                        ),
                      );
                    },
                    child: const Text('Visualizar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}