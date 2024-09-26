import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_img_detail_table.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/pages/template/app_template.dart';
import 'package:frontend/widgets/custom_dialog.dart'; // Importe o CustomDialog

class DetalheImgPage extends StatefulWidget {
  @override
  _DetalheImgPageState createState() => _DetalheImgPageState();
}

class _DetalheImgPageState extends State<DetalheImgPage> {
  Map<String, dynamic>? imageData;
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    fetchImageData();
  }

  Future<void> fetchImageData() async {
    final response =
        await http.get(Uri.parse('http://demo0152687.mockable.io/imgDetail'));
    if (response.statusCode == 200) {
      setState(() {
        imageData = jsonDecode(response.body);
      });
    } else {
      throw Exception('Falha ao carregar dados');
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
                  Image.network(
                    imageData!['thumbnail'] ?? '',
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
                    // Lógica para download
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
                  Image.network(
                    imageData!['thumbnail'] ?? '',
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