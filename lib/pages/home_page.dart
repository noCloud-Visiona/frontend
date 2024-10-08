import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _zoomLevel = 4.0;
  final MapController _mapController = MapController();

  final String _mapboxToken = dotenv.env["MAPBOX_TOKEN"] ?? '';

  String _currentLayer = 'hybrid';

  void _zoomIn() {
    setState(() {
      _zoomLevel += 2;
      _mapController.move(
          _mapController.initialCenter ?? const LatLng(-14.2350, -51.9253),
          _zoomLevel);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel -= 2;
      _mapController.move(
          _mapController.initialCenter ?? const LatLng(-14.2350, -51.9253),
          _zoomLevel);
    });
  }

  void _changeLayer(String layer) {
    setState(() {
      _currentLayer = layer;
    });
  }

  String _getLayerUrl() {
  switch (_currentLayer) {
    case 'hybrid':
      return 'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxToken&language=pt-BR';
    case 'satellite':
      return 'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxToken&language=pt-BR';
    case 'streets':
      return 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxToken&language=pt-BR';
    default:
      return 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxToken&language=pt-BR';
  }
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
              initialCenter: const LatLng(-14.2350, -51.9253), // Coordenadas centrais do Brasil
              initialZoom: _zoomLevel,
              maxZoom: 18.0,
              minZoom: 3.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _getLayerUrl(),
                additionalOptions: {
                  'accessToken': _mapboxToken,
                },
                subdomains: const ['a', 'b', 'c'],
              ),
            ],
          ),
          Positioned(
            right: 10,
            top: 10,
            child: FloatingActionButton(
              heroTag: 'layerButton',
              onPressed: () {},
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
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.layers),
                onSelected: _changeLayer,
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'hybrid',
                      child: Text('Híbrido'),
                    ),
                    const PopupMenuItem(
                      value: 'satellite',
                      child: Text('Satélite'),
                    ),
                    const PopupMenuItem(
                      value: 'streets',
                      child: Text('Ruas'),
                    ),
                  ];
                },
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomInButton',
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
                  heroTag: 'zoomOutButton',
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