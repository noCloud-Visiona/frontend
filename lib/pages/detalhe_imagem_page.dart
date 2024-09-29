import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_img_detail_table.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:frontend/widgets/custom_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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

  String _extractFileName(String url) {
    return url.split('/').last;
  }

  Future<void> _downloadImage(String url) async {
    try {
      // Solicitar permissões de armazenamento
      if (await Permission.storage.request().isGranted) {
        String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
        if (selectedDirectory == null) {
          // Usuário cancelou a seleção do diretório
          return;
        }

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final fileName = _extractFileName(url);
          final filePath = '$selectedDirectory/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download realizado com sucesso!')),
          );
          print('Imagem salva em: $filePath');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao baixar a imagem: ${response.statusCode}')),
          );
          print('Erro ao baixar a imagem: ${response.statusCode}');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissão de armazenamento negada')),
        );
        print('Permissão de armazenamento negada');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao baixar a imagem: $e')),
      );
      print('Erro ao baixar a imagem: $e');
    }
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
                    // Lógica para download em PDF
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
                      _downloadImage(imageData!['img_tratada']);
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
                        ElevatedButton(
                          onPressed: _showDownloadDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF176B87),
                            foregroundColor: Colors.white,
                            shadowColor: Colors.black,
                            elevation: 5,
                            side: const BorderSide(color: Colors.white, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), 
                            ),
                            minimumSize: const Size(48 , 48),
                          ),
                          child: const Icon(Icons.download, color: Colors.white),
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