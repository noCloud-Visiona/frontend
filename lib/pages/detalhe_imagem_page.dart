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
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    imageData!['img_tratada'] ?? '',
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Campo')),
                      DataColumn(label: Text('Valor')),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('ID')),
                        DataCell(Text(imageData!['id'] ?? '')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Data')),
                        DataCell(Text(imageData!['data'] ?? '')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Hora')),
                        DataCell(Text(imageData!['hora'] ?? '')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Resolução da Imagem')),
                        DataCell(Text(imageData!['resolucao_imagem'] ?? '')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Satélite')),
                        DataCell(Text(imageData!['satelite'] ?? '')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Sensor')),
                        DataCell(Text(imageData!['sensor'] ?? '')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Percentual de Nuvem')),
                        DataCell(Text('${imageData!['percentual_nuvem'] ?? ''}%')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Área Visível no Mapa')),
                        DataCell(Text('${imageData!['area_visivel_mapa'] ?? ''}%')),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}