import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/detalhe_imagem_page.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importando SharedPreferences

class AnalisarImgPage extends StatelessWidget {
  final String imgPath;

  const AnalisarImgPage({super.key, required this.imgPath});

  Future<void> _analisarImagem(BuildContext context) async {
    try {
      var apiUrl = dotenv.env['AI_API_URL'];
      if (apiUrl == null) {
        throw Exception('AI_API_URL não está definida no arquivo .env');
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception('userId não encontrado em SharedPreferences');
      }

      var uri = Uri.parse('$apiUrl/predict/$userId'); // Usando a variável de ambiente AI_API_URL

      var request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        var response = await http.get(Uri.parse(imgPath));
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          response.bodyBytes,
          filename: 'image.jpg',
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          imgPath,
        ));
      }

      print('Enviando imagem para análise...'); // Log para depuração

      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      if (streamedResponse.statusCode == 200) {
        print('Imagem enviada com sucesso, recebendo resposta...'); // Log para depuração
        var responseData = await streamedResponse.stream.toBytes().timeout(const Duration(seconds: 60));
        print('Resposta recebida, decodificando...'); // Log para depuração
        var responseString = utf8.decode(responseData);
        print('Resposta decodificada: $responseString'); // Log para depuração
        var jsonResponse = json.decode(responseString);

        // Decodificar a imagem tratada
        Uint8List? imageBytes;
        if (jsonResponse['img_tratada'] != null) {
          var response = await http.get(Uri.parse(jsonResponse['img_tratada']));
          imageBytes = response.bodyBytes;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalheImgPage(
              data: jsonResponse,
              imageBytes: imageBytes,
            ),
          ),
        );
      } else {
        print('Erro ao enviar imagem: ${streamedResponse.statusCode}');
        print('Erro ao enviar imagem: ${streamedResponse.reasonPhrase}');
      }
    } on TimeoutException catch (e) {
      print('Erro: Tempo limite excedido: $e');
    } on http.ClientException catch (e) {
      print('Erro: ClientException: $e');
    } catch (e) {
      print('Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return AppTemplate(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (kIsWeb)
              Image.network(
                imgPath,
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              )
            else
              Image.file(
                File(imgPath),
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _analisarImagem(context),
              child: const Text('Analisar'),
            ),
          ],
        ),
      ),
      currentIndex: 1,
    );
  }
}