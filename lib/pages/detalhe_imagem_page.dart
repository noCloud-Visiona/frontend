import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_img_detail_table.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/pages/template/app_template.dart';

class DetalheImgPage extends StatefulWidget {
  @override
  _DetalheImgPageState createState() => _DetalheImgPageState();
}

class _DetalheImgPageState extends State<DetalheImgPage> {
  Map<String, dynamic>? imageData;

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
                          onPressed: () {
                            // Lógica de download será adicionada aqui
                          },
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