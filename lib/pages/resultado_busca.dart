import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados da Pesquisa'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Data: ${startDate.toIso8601String().split('T').first} - ${endDate.toIso8601String().split('T').first}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Coordenadas: (${startPoint.latitude}, ${startPoint.longitude}) - (${endPoint.latitude}, ${endPoint.longitude})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
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
    );
  }
}