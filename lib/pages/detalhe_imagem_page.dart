import 'dart:convert';
import 'package:flutter/material.dart';
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
                    imageData!['img_tratada'] ?? '',
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(2),
                      },
                      border: TableBorder.all(color: Colors.black),
                      children: [
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Campo',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Valor',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('ID'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(imageData!['id'] ?? ''),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Data'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(imageData!['data'] ?? ''),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Hora'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(imageData!['hora'] ?? ''),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Resolução da Imagem'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(imageData!['resolucao_imagem'] ?? ''),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Satélite'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(imageData!['satelite'] ?? ''),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Sensor'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(imageData!['sensor'] ?? ''),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Percentual de Nuvem'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                '${imageData!['percentual_nuvem'] ?? ''}%'),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Área Visível no Mapa'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                '${imageData!['area_visivel_mapa'] ?? ''}%'),
                          ),
                        ]),
                      ],
                    ),
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
                            backgroundColor:
                                const Color(0xFF176B87), // Cor da navbar
                            foregroundColor: Colors.white,
                            shadowColor: Colors.black,
                            elevation: 5,
                            side:
                                const BorderSide(color: Colors.white, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Cantos arredondados em 5%
                            ),
                            minimumSize: const Size(48, 48), // Tamanho quadrado
                          ),
                          child:
                              const Icon(Icons.download, color: Colors.white),
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
