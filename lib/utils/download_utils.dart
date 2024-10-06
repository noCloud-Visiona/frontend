import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

Future<void> downloadImage(BuildContext context, String url) async {
  try {
    // Oferecer ao usuário a opção de selecionar o diretório
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      // Usuário cancelou a seleção do diretório
      return;
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
    Navigator.of(context).pop(); // Fechar a barra de progresso

    if (response.statusCode == 200) {
      final fileName = '${url.split('/').last.split('.').first}.png';
      final filePath = '$selectedDirectory/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Download realizado com sucesso!'),
          action: SnackBarAction(
            label: 'Abrir',
            onPressed: () async {
              final result = await OpenFile.open(filePath);
              if (result.type != ResultType.done) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao abrir o arquivo: ${result.message}')),
                );
              }
            },
          ),
        ),
      );
      print('Imagem salva em: $filePath');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao baixar a imagem: ${response.statusCode}')),
      );
      print('Erro ao baixar a imagem: ${response.statusCode}');
    }
  } catch (e) {
    Navigator.of(context).pop(); // Fechar a barra de progresso em caso de erro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao baixar a imagem: $e')),
    );
    print('Erro ao baixar a imagem: $e');
  }
}

Future<void> generatePdf(
    BuildContext context, Map<String, dynamic> imageData) async {
  final pdf = pw.Document();
  final image = imageData['img_tratada'] != null
      ? (await networkImage(imageData['img_tratada']))
      : null;

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            if (image != null) pw.Image(image),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(3),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Text('Campo',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Valor',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('ID'),
                    pw.Text('${imageData['id'] ?? ''}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Data'),
                    pw.Text('${imageData['data'] ?? ''}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Hora'),
                    pw.Text('${imageData['hora'] ?? ''}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Resolução da Imagem'),
                    pw.Text('${imageData['resolucao_imagem'] ?? ''}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Satélite'),
                    pw.Text('${imageData['satelite'] ?? ''}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Sensor'),
                    pw.Text('${imageData['sensor'] ?? ''}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Percentual de Nuvem'),
                    pw.Text('${imageData['percentual_nuvem'] ?? ''}%'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Área Visível no Mapa'),
                    pw.Text('${imageData['area_visivel_mapa'] ?? ''}%'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Thumbnail'),
                    pw.UrlLink(
                      destination: imageData['thumbnail'],
                      child: pw.Text(
                        imageData['thumbnail'],
                        style: const pw.TextStyle(
                          color: PdfColors.blue,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Imagem Analisada'),
                    pw.UrlLink(
                      destination: imageData['img_tratada'],
                      child: pw.Text(
                        imageData['img_tratada'],
                        style: const pw.TextStyle(
                          color: PdfColors.blue,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  // Oferecer ao usuário a opção de selecionar o diretório
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
  if (selectedDirectory == null) {
    // Usuário cancelou a seleção do diretório
    return;
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
              Text('Gerando PDF...'),
            ],
          ),
        ),
      );
    },
  );

  // Usar a ID da análise como parte do nome do arquivo
  final fileName = '${imageData['id'] ?? 'sem_id'}.pdf';
  final filePath = '$selectedDirectory/$fileName';
  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());

  Navigator.of(context).pop(); // Fechar a barra de progresso

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('PDF gerado com sucesso!'),
      action: SnackBarAction(
        label: 'Abrir',
        onPressed: () async {
          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao abrir o arquivo: ${result.message}')),
            );
          }
        },
      ),
    ),
  );
  print('PDF salvo em: $filePath');
}

Future<pw.ImageProvider> networkImage(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return pw.MemoryImage(response.bodyBytes);
  } else {
    throw Exception('Erro ao carregar a imagem da URL: ${response.statusCode}');
  }
}