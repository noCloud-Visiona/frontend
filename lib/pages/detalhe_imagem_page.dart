import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_img_detail_table.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:frontend/widgets/custom_dialog.dart';
import 'package:frontend/widgets/download_button.dart';
import 'package:frontend/utils/download_utils.dart'; // Importando o arquivo utilitário

class DetalheImgPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final Uint8List? imageBytes;

  const DetalheImgPage({super.key, required this.data, this.imageBytes});

  @override
  _DetalheImgPageState createState() => _DetalheImgPageState();
}

class _DetalheImgPageState extends State<DetalheImgPage> {
  Map<String, dynamic>? imageData;
  bool _isSelected = false;

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
              title: 'Selecione a imagem para download',
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        _isSelected = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  if (imageData != null && imageData!['img_tratada'] != null)
                    Image.network(
                      imageData!['img_tratada'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
              actions: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF'),
                  onPressed: () {
                    Navigator.of(context).pop(); 
                    generatePdf(context, imageData!);
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
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  onPressed: () {
                    if (_isSelected && imageData != null && imageData!['img_tratada'] != null) {
                      Navigator.of(context).pop(); // Fechar o diálogo
                      downloadImage(context, imageData!['img_tratada']); // Usando a função importada
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
                  if (imageData!['img_tratada'] != null)
                    Image.network(
                      imageData!['img_tratada'],
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 20),
                  CustomTable(
                    data: [
                      {'campo': 'ID', 'valor': imageData!['id'] ?? ''},
                      {'campo': 'Data', 'valor': imageData!['data'] ?? ''},
                      {'campo': 'Hora', 'valor': imageData!['hora'] ?? ''},
                      {'campo': 'Resolução da Imagem', 'valor': imageData!['resolucao_imagem'] ?? ''},
                      {'campo': 'Satélite', 'valor': imageData!['satelite'] ?? ''},
                      {'campo': 'Sensor', 'valor': imageData!['sensor'] ?? ''},
                      {'campo': 'Percentual de Nuvem', 'valor': '${imageData!['percentual_nuvem'] ?? ''}%'},
                      {'campo': 'Área Visível no Mapa', 'valor': '${imageData!['area_visivel_mapa'] ?? ''}%'},
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        DownloadButton(
                          onDownloadImage: () => downloadImage(context, imageData!['img_tratada']),
                          onDownloadPdf: () => generatePdf(context, imageData!),
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