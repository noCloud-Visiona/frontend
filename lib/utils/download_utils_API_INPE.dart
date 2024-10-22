import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html; // Para baixar no Web

// Função para baixar imagens tanto no Android quanto no Web
Future<String?> downloadImgINPE(BuildContext context, String url, String id, {bool isCloudMask = false}) async {
  try {
    String? selectedDirectory;

    if (kIsWeb) {
      // Web: Criar um link de download e baixar a imagem no navegador
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final fileName = isCloudMask ? '${id}_cloud_mask.png' : '$id.png';
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);

        return fileName;
      } else {
        throw Exception('Erro ao baixar a imagem: ${response.statusCode}');
      }
    } else {
      // Android/iOS: Oferecer ao usuário a opção de selecionar o diretório
      selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return null; // Usuário cancelou a seleção
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final fileName = isCloudMask ? '${id}_cloud_mask.png' : '$id.png';
        final filePath = '$selectedDirectory/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return filePath;
      } else {
        throw Exception('Erro ao baixar a imagem: ${response.statusCode}');
      }
    }
  } catch (e) {
    throw Exception('Erro ao baixar a imagem: $e');
  }
}