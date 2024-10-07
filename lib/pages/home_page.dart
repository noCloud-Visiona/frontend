import 'package:flutter/material.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTemplate(
      currentIndex: 0,
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(-23.5505, -46.6333), // Exemplo: São Paulo
          maxZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}
