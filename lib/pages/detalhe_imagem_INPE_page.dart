import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_img_detail_table.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:frontend/widgets/custom_dialog.dart';
import 'package:frontend/utils/download_utils_API_INPE.dart'; // Importando o arquivo utilitário
import 'package:frontend/utils/generate_Pdf_INPE.dart'; // Importando o arquivo de geração de PDF
import 'package:intl/intl.dart'; // Importando a biblioteca intl
import 'package:open_file/open_file.dart'; // Importando a biblioteca open_file

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
              title: 'Selecione as Imagens', // Adicionando o título
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
                Center(
                  // Centralizando o botão
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    onPressed: () async {
                      Navigator.of(context).pop(); // Fechar o diálogo

                      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory == null) {
                        return; // Usuário cancelou a seleção
                      }

                      if (_isSelectedTratada &&
                          imageData != null &&
                          imageData!['identificacao_ia'] != null &&
                          imageData!['identificacao_ia']['thumbnail_imagem_url'] != null) {
                        await _downloadImage(
                            imageData!['identificacao_ia']['thumbnail_imagem_url'],
                            imageData!['identificacao_ia']['id'],
                            selectedDirectory: selectedDirectory);
                      }
                      if (_isSelectedMascara &&
                          imageData != null &&
                          imageData!['identificacao_ia'] != null &&
                          imageData!['identificacao_ia']['mask_nuvem'] != null) {
                        await _downloadImage(
                            imageData!['identificacao_ia']['mask_nuvem'],
                            imageData!['identificacao_ia']['id'],
                            isCloudMask: true,
                            selectedDirectory: selectedDirectory);
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
                Text('Fazendo o download do arquivo...'),
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
          title: const Text('Download Concluído'),
          content: const Text('O download foi realizado com sucesso!'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await OpenFile.open(filePath);
                if (result.type != ResultType.done && context.mounted) {
                  _showErrorDialog(
                      context, 'Erro ao abrir o arquivo: ${result.message}');
                }
              },
              child: const Text('Abrir arquivo'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadImage(String url, String id,
      {bool isCloudMask = false, String? selectedDirectory}) async {
    _showProgressDialog();
    try {
      final filePath = await downloadImgINPE(context, url, id,
          isCloudMask: isCloudMask, selectedDirectory: selectedDirectory);
      if (context.mounted) {
        Navigator.of(context).pop(); // Fechar o diálogo de progresso
        if (filePath != null) {
          _showSuccessDialog(filePath);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fechar o diálogo de progresso
        _showErrorDialog(context, e.toString());
      }
    }
  }

  Future<void> _downloadPdf() async {
    _showProgressDialog();
    try {
      final filePath = await generateINPEPdf(context, imageData!);
      if (context.mounted) {
        Navigator.of(context).pop(); // Fechar o diálogo de progresso
        if (filePath != null) {
          _showSuccessDialog(filePath);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Fechar o diálogo de progresso
        _showErrorDialog(context, e.toString());
      }
    }
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

  String _formatCoordinates(List<dynamic> coordinates) {
    if (coordinates.isEmpty || coordinates[0].isEmpty) {
      return 'Coordenadas não disponíveis';
    }
    final coordList = coordinates[0];
    return coordList.map((coord) => '(${coord[1]}, ${coord[0]})').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return AppTemplate(
      currentIndex: 1,
      body: Stack(
        children: [
          imageData == null
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
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            if (imageData!['identificacao_ia']['thumbnail_imagem_url'] !=
                                null)
                              Image.network(
                                imageData!['identificacao_ia']['thumbnail_imagem_url'],
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Detalhes da Imagem Processada',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      CustomTable(
                        data: [
                          {'campo': 'ID', 'valor': imageData!['id'] ?? ''},
                          {
                            'campo': 'Data',
                            'valor': imageData!['identificacao_ia'] != null && imageData!['identificacao_ia']['data'] != null
                                ? _formatDate(imageData!['identificacao_ia']['data'])
                                : ''
                          },
                          {'campo': 'Hora', 'valor': imageData!['identificacao_ia'] != null && imageData!['identificacao_ia']['hora'] != null
                                ? imageData!['identificacao_ia']['hora']
                                : ''
                          },
                          {
                            'campo': 'Resolução da Imagem',
                            'valor': imageData!['identificacao_ia'] != null
                                ? imageData!['identificacao_ia']
                                        ['resolucao_imagem_png'] ??
                                    ''
                                : ''
                          },
                          {
                            'campo': 'Coleção',
                            'valor': imageData!['collection'] ?? ''
                          },
                          {
                            'campo': 'Satélite',
                            'valor': imageData!['collection'] ?? ''
                          },
                          {
                            'campo': 'Percentual de Nuvem',
                            'valor': imageData!['identificacao_ia'] != null
                                ? '${imageData!['identificacao_ia']['percentual_nuvem'] ?? ''}%'
                                : ''
                          },
                          {
                            'campo': 'Área Visível no Mapa',
                            'valor': imageData!['identificacao_ia'] != null
                                ? '${imageData!['identificacao_ia']['area_visivel_mapa'] ?? ''}%'
                                : ''
                          },
                          {
                            'campo': 'Coordenadas',
                            'valor': imageData!['user_geometry'] != null &&
                                    imageData!['user_geometry']
                                            ['coordinates'] !=
                                        null
                                ? _formatCoordinates(
                                    imageData!['user_geometry']['coordinates'])
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Thumbnail',
                            'valor': imageData!['assets'] != null &&
                                    imageData!['assets']['thumbnail'] != null
                                ? imageData!['assets']['thumbnail']['href']
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Máscara de Nuvem',
                            'valor': imageData!['identificacao_ia'] != null &&
                                    imageData!['identificacao_ia']
                                            ['mask_nuvem'] !=
                                        null
                                ? imageData!['identificacao_ia']['mask_nuvem']
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Imagem Tiff',
                            'valor': imageData!['assets'] != null &&
                                    imageData!['assets']['EVI'] != null
                                ? imageData!['assets']['EVI']['href']
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Imagem Sem Nuvem',
                            'valor': imageData!['identificacao_ia'] != null &&
                                    imageData!['identificacao_ia']
                                            ['imagem_sem_nuvem_url'] !=
                                        null
                                ? imageData!['identificacao_ia']
                                    ['imagem_sem_nuvem_url']
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Imagem Sem Sombra',
                            'valor': imageData!['identificacao_ia'] != null &&
                                    imageData!['identificacao_ia']
                                            ['imagem_sem_sombra_url'] !=
                                        null
                                ? imageData!['identificacao_ia']
                                    ['imagem_sem_sombra_url']
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Imagem Nuvem',
                            'valor': imageData!['identificacao_ia'] != null &&
                                    imageData!['identificacao_ia']
                                            ['imagem_nuvem_url'] !=
                                        null
                                ? imageData!['identificacao_ia']
                                    ['imagem_nuvem_url']
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Imagem Sombra',
                            'valor': imageData!['identificacao_ia'] != null &&
                                    imageData!['identificacao_ia']
                                            ['imagem_sombra_url'] !=
                                        null
                                ? imageData!['identificacao_ia']
                                    ['imagem_sombra_url']
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Thumbnail Sem Nuvem',
                            'valor': imageData!['identificacao_ia'] != null &&
                                    imageData!['identificacao_ia']
                                            ['thumbnail_sem_nuvem_url'] !=
                                        null
                                ? imageData!['identificacao_ia']
                                    ['thumbnail_sem_nuvem_url']
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Thumbnail Sem Sombra',
                            'valor': imageData!['identificacao_ia'] != null &&
                                    imageData!['identificacao_ia']
                                            ['thumbnail_sem_sombra_url'] !=
                                        null
                                ? imageData!['identificacao_ia']
                                    ['thumbnail_sem_sombra_url']
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Thumbnail Nuvem',
                            'valor': imageData!['identificacao_ia'] != null &&
                                    imageData!['identificacao_ia']
                                            ['thumbnail_nuvem_url'] !=
                                        null
                                ? imageData!['identificacao_ia']
                                    ['thumbnail_nuvem_url']
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Thumbnail Sombra',
                            'valor': imageData!['identificacao_ia'] != null &&
                                    imageData!['identificacao_ia']
                                            ['thumbnail_sombra_url'] !=
                                        null
                                ? imageData!['identificacao_ia']
                                    ['thumbnail_sombra_url']
                                : 'Não se Aplica'
                          },
                          {
                            'campo': 'Thumbnail Imagem',
                            'valor': imageData!['identificacao_ia'] != null &&
                                    imageData!['identificacao_ia']
                                            ['thumbnail_imagem_url'] !=
                                        null
                                ? imageData!['identificacao_ia']
                                    ['thumbnail_imagem_url']
                                : 'Não se Aplica'
                          },
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'uniqueTag1',
                  onPressed: _showDownloadDialog,
                  backgroundColor: const Color(0xFF176B87),
                  foregroundColor: Colors.white, // Ícone na cor branca
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                        color: Colors.white,
                        width: 1), // Borda de 1px na cor branca
                  ),
                  elevation: 5, // Sombra para mostrar que o botão está suspenso
                  child: const Icon(Icons.download),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'uniqueTag2',
                  onPressed: _downloadPdf,
                  backgroundColor: const Color(0xFF176B87),
                  foregroundColor: Colors.white, // Ícone na cor branca
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                        color: Colors.white,
                        width: 1), // Borda de 1px na cor branca
                  ),
                  elevation: 5, // Sombra para mostrar que o botão está suspenso
                  child: const Icon(Icons.picture_as_pdf),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: 'uniqueTag3',
              onPressed: () {
                // Ação ao clicar no botão de mapa
              },
              backgroundColor: const Color(0xFF176B87),
              foregroundColor: Colors.white, // Ícone na cor branca
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                    color: Colors.white,
                    width: 1), // Borda de 1px na cor branca
              ),
              elevation: 5, // Sombra para mostrar que o botão está suspenso
              child: const Icon(Icons.map),
            ),
          ),
        ],
      ),
    );
  }
}