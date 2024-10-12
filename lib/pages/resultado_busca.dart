import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:intl/intl.dart';

class ResultadoBuscaPage extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final LatLng startPoint;
  final LatLng endPoint;
  final List<dynamic> features;

  const ResultadoBuscaPage({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.startPoint,
    required this.endPoint,
    required this.features,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcular as coordenadas Norte, Sul, Leste e Oeste
    final double north = startPoint.latitude > endPoint.latitude
        ? startPoint.latitude
        : endPoint.latitude;
    final double south = startPoint.latitude < endPoint.latitude
        ? startPoint.latitude
        : endPoint.latitude;
    final double west = startPoint.longitude < endPoint.longitude
        ? startPoint.longitude
        : endPoint.longitude;
    final double east = startPoint.longitude > endPoint.longitude
        ? startPoint.longitude
        : endPoint.longitude;

    // Formatar as datas no formato pt-BR
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
    final String formattedStartDate = dateFormat.format(startDate);
    final String formattedEndDate = dateFormat.format(endDate);

    // Formatar as coordenadas com 4 casas decimais
    final String formattedNorth = north.toStringAsFixed(4);
    final String formattedSouth = south.toStringAsFixed(4);
    final String formattedWest = west.toStringAsFixed(4);
    final String formattedEast = east.toStringAsFixed(4);

    return AppTemplate(
      currentIndex: 0,
      body: Scaffold(
        appBar: AppBar(
          title: const Text('Resultados da Pesquisa'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Data: $formattedStartDate - $formattedEndDate',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(thickness: 2),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Coordenadas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Text('NORTE: $formattedNorth', style: const TextStyle(fontSize: 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('OESTE: $formattedWest',
                          style: const TextStyle(fontSize: 16)),
                      Text('LESTE: $formattedEast',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  Text('SUL: $formattedSouth', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const Divider(thickness: 2),
            Expanded(
              child: ListView.builder(
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];
                  final id = feature['id'];
                  final thumbnailUrl = feature['assets']['thumbnail']['href'];

                  return ListTile(
                    leading: Image.network(thumbnailUrl),
                    title: Text('ID: $id'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}