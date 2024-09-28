import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:frontend/pages/detalhe_imagem_page.dart';
import 'package:frontend/pages/template/app_template.dart';

class AnalisarImgPage extends StatelessWidget {
  final String imgPath;
  const AnalisarImgPage({super.key, required this.imgPath});

  Future<void> _analisarImagem(BuildContext context) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://172.29.224.1:5000/predict'),
      );

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

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var contentType = response.headers['content-type'];
        var boundary = contentType!.split('boundary=')[1];

        var parts = MimeMultipartTransformer(boundary)
            .bind(Stream.fromIterable([responseData]))
            .map((part) async {
          var headers = part.headers;
          var content = await part.toList();
          var contentBytes = content.expand((x) => x).toList();

          if (headers['content-type'] == 'application/json') {
            return utf8.decode(contentBytes);
          } else if (headers['content-type'] == 'image/png') {
            return contentBytes;
          }
          return null;
        }).toList();

        var jsonResponse = '';
        Uint8List? imageBytes;

        for (var part in await Future.wait(parts as Iterable<Future>)) {
          if (part is String) {
            jsonResponse = part;
          } else if (part is List<int>) {
            imageBytes = Uint8List.fromList(part);
          }
        }

        var jsonMap = json.decode(jsonResponse);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalheImgPage(data: jsonMap, imageBytes: imageBytes),
          ),
        );
      } else {
        print('Erro ao enviar imagem: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Exibindo imagem em AnalisarImgPage com imgPath: $imgPath'); // Log para depuração

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