import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/pages/template/app_template.dart';

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
                'Data: ${startDate.toIso8601String().split('T').first} - ${endDate.toIso8601String().split('T').first}',
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
                  Text('NORTE: $north', style: const TextStyle(fontSize: 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('OESTE: $west',
                          style: const TextStyle(fontSize: 16)),
                      Text('LESTE: $east',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  Text('SUL: $south', style: const TextStyle(fontSize: 16)),
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
