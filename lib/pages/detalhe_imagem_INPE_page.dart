import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_img_detail_table.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:frontend/widgets/custom_dialog.dart';
import 'package:frontend/widgets/download_button.dart';
import 'package:frontend/utils/download_utils_API_INPE.dart'; // Importando o arquivo utilitário
import 'package:intl/intl.dart'; // Importando a biblioteca intl

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
                      downloadImgINPE(context, imageData!['identificacao_ia']['img_tratada']);
                    }
                    if (_isSelectedMascara && imageData != null && imageData!['identificacao_ia'] != null && imageData!['identificacao_ia']['mask_nuvem'] != null) {
                      downloadImgINPE(context, imageData!['identificacao_ia']['mask_nuvem']);
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

  void _showProgressDialog(BuildContext context) {
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
                Text('Iniciando geração do PDF...'),
              ],
            ),
          ),
        );
      },
    );
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
                            _showProgressDialog(context);
                            await generateINPEPdf(context, imageData!);
                            Navigator.of(context).pop();
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