import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/utils/download_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

Future<String?> generateINPEPdf(BuildContext context, Map<String, dynamic> imageData) async {
  print('Iniciando geração do PDF');
  final pdf = pw.Document();
  final image = imageData['identificacao_ia'] != null && imageData['identificacao_ia']['img_tratada'] != null
      ? (await networkImage(imageData['identificacao_ia']['img_tratada']))
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
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(3),
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
                    pw.Text('${imageData['identificacao_ia'] != null ? imageData['identificacao_ia']['resolucao_imagem_png'] ?? '' : ''}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Satélite'),
                    pw.Text('${imageData['collection'] ?? ''}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Percentual de Nuvem'),
                    pw.Text('${imageData['identificacao_ia'] != null ? '${imageData['identificacao_ia']['percentual_nuvem'] ?? ''}%' : ''}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Área Visível no Mapa'),
                    pw.Text('${imageData['identificacao_ia'] != null ? '${imageData['identificacao_ia']['area_visivel_mapa'] ?? ''}%' : ''}'),
                  ],
                ),
                if (imageData['assets'] != null && imageData['assets']['thumbnail'] != null)
                  pw.TableRow(
                    children: [
                      pw.Text('Thumbnail'),
                      pw.UrlLink(
                        destination: imageData['assets']['thumbnail']['href'],
                        child: pw.Text(
                          imageData['assets']['thumbnail']['href'],
                          style: const pw.TextStyle(
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (imageData['identificacao_ia'] != null && imageData['identificacao_ia']['img_tratada'] != null)
                  pw.TableRow(
                    children: [
                      pw.Text('Imagem Analisada'),
                      pw.UrlLink(
                        destination: imageData['identificacao_ia']['img_tratada'],
                        child: pw.Text(
                          imageData['identificacao_ia']['img_tratada'],
                          style: const pw.TextStyle(
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (imageData['identificacao_ia'] != null && imageData['identificacao_ia']['mask_nuvem'] != null)
                  pw.TableRow(
                    children: [
                      pw.Text('Máscara de Nuvem'),
                      pw.UrlLink(
                        destination: imageData['identificacao_ia']['mask_nuvem'],
                        child: pw.Text(
                          imageData['identificacao_ia']['mask_nuvem'],
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

  if (kIsWeb) {
    // Web: Criar um link de download para o PDF
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "${imageData['id'] ?? 'sem_id'}.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);

    return null;
  } else {
    // Android/iOS: Oferecer ao usuário a opção de selecionar o diretório
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      return null;
    }

    final fileName = '${imageData['id'] ?? 'sem_id'}.pdf';
    final filePath = '$selectedDirectory/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }
}