import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/pages/visualizar_img_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalisarImgINPEpage extends StatelessWidget {
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

  Future<void> _analisarImagem(BuildContext context) async {
    try {
      // Criar o JSON com os dados da imagem e as coordenadas do usuário
      var requestData = {
        "type": featureData["type"],
        "id": featureData["id"],
        "collection": featureData["collection"],
        "stac_version": featureData["stac_version"],
        "stac_extensions": featureData["stac_extensions"],
        "geometry": featureData["geometry"],
        "links": featureData["links"],
        "bbox": featureData["bbox"],
        "assets": featureData["assets"],
        "thumbnail": featureData["thumbnail"],
        "properties": featureData["properties"],
        "user_geometry": {
          "type": "Polygon",
          "coordinates": [
            [
              [west, south],
              [west, north],
              [east, north],
              [east, south],
              [west, south]
            ]
          ]
        }
      };

      print('JSON a ser enviado: ${json.encode(requestData)}');

      // Definir a URL da API
      var apiUrl = dotenv.env['AI_API_URL'];
      var uri = Uri.parse('$apiUrl/predict');

      // Fazer o POST com o JSON
      var response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestData),
      );

      // Verificar a resposta
      if (response.statusCode == 201) {
        Navigator.pop(context);

        print('Resposta do servidor: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagem analisada com sucesso!')),
        );
      } else {
        throw Exception(
            'Falha ao analisar imagem. Código: ${response.statusCode}');
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

  @override
  Widget build(BuildContext context) {
    return AppTemplate(
      currentIndex: 1,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: $id',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 2),
            Center(
              child: Text('NORTE: ${north.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 16)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('OESTE: ${west.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 16)),
                Text('LESTE: ${east.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            Center(
              child: Text('SUL: ${south.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 16)),
            ),
            const Divider(thickness: 2),
            Text('Data: $datetime', style: const TextStyle(fontSize: 16)),
            const Divider(thickness: 2),
            Center(
              child: Column(
                children: [
                  if (kIsWeb)
                    Image.network(
                      thumbnailUrl,
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  else
                    Image.network(
                      thumbnailUrl,
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
                            featureData: featureData,
                            north: north,
                            south: south,
                            east: east,
                            west: west,
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
