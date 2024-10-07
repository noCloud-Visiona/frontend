import 'package:flutter/material.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _zoomLevel = 13.0;
  final MapController _mapController = MapController();

  void _zoomIn() {
    setState(() {
      _zoomLevel += 3;
      _mapController.move(
          _mapController.initialCenter ?? const LatLng(-23.5505, -46.6333),
          _zoomLevel);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel -= 3;
      _mapController.move(
          _mapController.initialCenter ?? const LatLng(-23.5505, -46.6333),
          _zoomLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTemplate(
      currentIndex: 0,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  const LatLng(-23.5505, -46.6333), // Exemplo: São Paulo
              initialZoom: _zoomLevel,
              maxZoom: 18.0,
              minZoom: 3.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
            ],
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _zoomIn,
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF176B87),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                        color: Color(0xFF176B87),
                        width: 1), // Adiciona a borda de 1px
                  ),
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF176B87),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                        color: Color(0xFF176B87),
                        width: 1), // Adiciona a borda de 1px
                  ),
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on MapController {
  get initialCenter => null;
}
