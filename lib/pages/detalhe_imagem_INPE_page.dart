import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/utils/download_utils.dart';
import 'package:frontend/widgets/custom_img_detail_table.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:frontend/widgets/custom_dialog.dart';
import 'package:frontend/widgets/download_button.dart';
import 'package:frontend/utils/download_utils_API_INPE.dart'; // Importando o arquivo utilitário
import 'package:intl/intl.dart'; // Importando a biblioteca intl
import 'package:open_file/open_file.dart'; // Importando a biblioteca open_file
import 'package:file_picker/file_picker.dart'; // Importando a biblioteca file_picker
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Importando a biblioteca pdf
import 'package:universal_html/html.dart' as html; // Para baixar no Web
import 'package:flutter/foundation.dart' show kIsWeb;

class DetalheImgINPEPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final Uint8List? imageBytes;

  const DetalheImgINPEPage({super.key, required this.data, this.imageBytes});

  @override
  _DetalheImgINPEPageState createState() => _DetalheImgINPEPageState();
}

class _DetalheImgINPEPageState extends State<DetalheImgINPEPage> {
  Map<String, dynamic>? imageData;
  bool _isSelectedTratada = false;
  bool _isSelectedMascara = false;

  @override
  void initState() {
    super.initState();
    imageData = widget.data;
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CustomDialog(
              title: 'Selecione as imagens para download',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _isSelectedTratada,
                        onChanged: (bool? value) {
                          setState(() {
                            _isSelectedTratada = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text('Imagem Tratada'),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _isSelectedMascara,
                        onChanged: (bool? value) {
                          setState(() {
                            _isSelectedMascara = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text('Máscara de Nuvem'),
                    ],
                  ),
                ],
              ),
              actions: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fechar o diálogo
                    if (_isSelectedTratada && imageData != null && imageData!['identificacao_ia'] != null && imageData!['identificacao_ia']['img_tratada'] != null) {
                      _downloadImage(imageData!['identificacao_ia']['img_tratada']);
                    }
                    if (_isSelectedMascara && imageData != null && imageData!['identificacao_ia'] != null && imageData!['identificacao_ia']['mask_nuvem'] != null) {
                      _downloadImage(imageData!['identificacao_ia']['mask_nuvem']);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF176B87),
                    foregroundColor: Colors.white,
                    shadowColor: Colors.black,
                    elevation: 5,
                    side: const BorderSide(color: Colors.white, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    minimumSize: const Size(48, 48),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showProgressDialog() {
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
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Download realizado com sucesso!'),
          content: const Text('A imagem foi baixada com sucesso.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await OpenFile.open(filePath);
                if (result.type != ResultType.done && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao abrir o arquivo: ${result.message}')),
                  );
                }
              },
              child: const Text('Abrir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadImage(String url) async {
    _showProgressDialog();
    final filePath = await downloadImgINPE(context, url);
    if (context.mounted) {
      Navigator.of(context).pop(); // Fechar o diálogo de progresso
      if (filePath != null) {
        _showSuccessDialog(filePath);
      }
    }
  }

  Future<void> generateINPEPdf(BuildContext context, Map<String, dynamic> imageData) async {
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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF gerado e baixado com sucesso!')),
        );
      }
    } else {
      // Android/iOS: Oferecer ao usuário a opção de selecionar o diretório
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return;
      }

      final fileName = '${imageData['id'] ?? 'sem_id'}.pdf';
      final filePath = '$selectedDirectory/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF gerado com sucesso!'),
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
    }
    print('PDF gerado com sucesso');
  }

  String _formatDate(String dateStr) {
    try {
      final DateTime dateTime = DateTime.parse(dateStr);
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatCoordinates(Map<String, dynamic> coordinates) {
    return 'Norte: ${coordinates['coordinate1']['latitude']}\n'
           'Sul: ${coordinates['coordinate2']['latitude']}\n'
           'Leste: ${coordinates['coordinate3']['longitude']}\n'
           'Oeste: ${coordinates['coordinate4']['longitude']}';
  }

  @override
  Widget build(BuildContext context) {
    return AppTemplate(
      currentIndex: 1,
      body: imageData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  if (imageData!['identificacao_ia'] != null)
                    Column(
                      children: [
                        Text(
                          '${imageData!['identificacao_ia']['id'] ?? ''}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        if (imageData!['identificacao_ia']['img_tratada'] != null)
                          Image.network(
                            imageData!['identificacao_ia']['img_tratada'],
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Detalhes da Imagem Processada',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CustomTable(
                    data: [
                      {'campo': 'ID', 'valor': imageData!['id'] ?? ''},
                      {'campo': 'Data', 'valor': imageData!['data'] != null ? _formatDate(imageData!['data']) : ''},
                      {'campo': 'Hora', 'valor': imageData!['hora'] ?? ''},
                      {'campo': 'Resolução da Imagem', 'valor': imageData!['identificacao_ia'] != null ? imageData!['identificacao_ia']['resolucao_imagem_png'] ?? '' : ''},
                      {'campo': 'Coleção', 'valor': imageData!['collection'] ?? ''},
                      {'campo': 'Satélite', 'valor': imageData!['collection'] ?? ''},
                      {'campo': 'Percentual de Nuvem', 'valor': imageData!['identificacao_ia'] != null ? '${imageData!['identificacao_ia']['percentual_nuvem'] ?? ''}%' : ''},
                      {'campo': 'Área Visível no Mapa', 'valor': imageData!['identificacao_ia'] != null ? '${imageData!['identificacao_ia']['area_visivel_mapa'] ?? ''}%' : ''},
                      {'campo': 'Coordenadas', 'valor': _formatCoordinates(imageData!['user_geometry']['coordinates'])},
                      {'campo': 'Thumbnail', 'valor': imageData!['assets'] != null && imageData!['assets']['thumbnail'] != null ? imageData!['assets']['thumbnail']['href'] : 'Não se Aplica'},
                      {'campo': 'Máscara de Nuvem', 'valor': imageData!['identificacao_ia'] != null && imageData!['identificacao_ia']['mask_nuvem'] != null ? imageData!['identificacao_ia']['mask_nuvem'] : 'Não se Aplica'},
                      {'campo': 'Imagem Tiff', 'valor': imageData!['assets'] != null && imageData!['assets']['EVI'] != null ? imageData!['assets']['EVI']['href'] : 'Não se Aplica'},
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DownloadButton(
                          onDownloadImage: _showDownloadDialog,
                          onDownloadPdf: () async {
                            print('Botão de download do PDF clicado');
                            _showProgressDialog();
                            await generateINPEPdf(context, imageData!);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          onDownload: _showDownloadDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }
}