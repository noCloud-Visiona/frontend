import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html; // Para baixar no Web

// Função para baixar imagens tanto no Android quanto no Web
Future<String?> downloadImgINPE(BuildContext context, String url) async {
  try {
    String? selectedDirectory;

    if (kIsWeb) {
      // Web: Criar um link de download e baixar a imagem no navegador
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "imagem.png")
          ..click();
        html.Url.revokeObjectUrl(url);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagem baixada com sucesso!')),
          );
        }
        return null;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao baixar a imagem: ${response.statusCode}')),
          );
        }
        return null;
      }
    } else {
      // Android/iOS: Oferecer ao usuário a opção de selecionar o diretório
      selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return null; // Usuário cancelou a seleção
      }

      // Mostrar barra de progresso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Baixando imagem...'),
                ],
              ),
            ),
          );
        },
      );

      final response = await http.get(Uri.parse(url));
      if (context.mounted) {
        Navigator.of(context).pop(); // Fechar a barra de progresso
      }

      if (response.statusCode == 200) {
        final fileName = '${url.split('/').last.split('.').first}.png';
        final filePath = '$selectedDirectory/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Download realizado com sucesso!'),
              action: SnackBarAction(
                label: 'Abrir',
                onPressed: () async {
                  final result = await OpenFile.open(filePath);
                  if (result.type != ResultType.done && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao abrir o arquivo: ${result.message}')),
                    );
                  }
                },
              ),
            ),
          );
        }
        return filePath;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao baixar a imagem: ${response.statusCode}')),
          );
        }
        return null;
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao baixar a imagem: $e')),
      );
    }
    return null;
  }
}