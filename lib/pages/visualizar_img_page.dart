import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:frontend/pages/template/app_template.dart';

class VisualizarImagemPage extends StatefulWidget {
  final Map<String, dynamic> featureData;
  final double north;
  final double south;
  final double east;
  final double west;

  const VisualizarImagemPage({
    Key? key,
    required this.featureData,
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  }) : super(key: key);

  @override
  _VisualizarImagemPageState createState() => _VisualizarImagemPageState();
}

class _VisualizarImagemPageState extends State<VisualizarImagemPage> {
  final MapController _mapController = MapController();
  String _currentLayer = 'hybrid';

  Future<void> _analisarImagem(BuildContext context) async {
    try {
      // Criar o JSON com os dados da imagem e as coordenadas do usuário
      var requestData = {
        "type": widget.featureData["type"],
        "id": widget.featureData["id"],
        "collection": widget.featureData["collection"],
        "stac_version": widget.featureData["stac_version"],
        "stac_extensions": widget.featureData["stac_extensions"],
        "geometry": widget.featureData["geometry"],
        "links": widget.featureData["links"],
        "bbox": widget.featureData["bbox"],
        "assets": widget.featureData["assets"],
        "properties": widget.featureData["properties"],
        "user_geometry": {
          "type": "Polygon",
          "coordinates": [
            [
              [widget.west, widget.south],
              [widget.west, widget.north],
              [widget.east, widget.north],
              [widget.east, widget.south],
              [widget.west, widget.south]
            ]
          ]
        }
      };

      // Imprimir o JSON no terminal
      print('JSON a ser enviado: ${json.encode(requestData)}');

      // Simular um atraso para mostrar o diálogo de carregamento
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON impresso no terminal')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Processando imagem...'),
            ],
          ),
        );
      },
    );
  }

  void _changeLayer(String layer) {
    setState(() {
      _currentLayer = layer;
    });
  }

  String _getLayerUrl() {
    final String mapboxToken = dotenv.env["MAPBOX_TOKEN"] ?? '';
    switch (_currentLayer) {
      case 'hybrid':
        return 'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken&language=pt-BR';
      case 'satellite':
        return 'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken&language=pt-BR';
      case 'streets':
        return 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken&language=pt-BR';
      default:
        return 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken&language=pt-BR';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String mapboxToken = dotenv.env["MAPBOX_TOKEN"] ?? '';

    // Extrair dados do JSON
    final bbox = widget.featureData['bbox'];
    final thumbnailUrl = widget.featureData['assets']['thumbnail']['href'];

    final imageNorth = bbox[3];
    final imageSouth = bbox[1];
    final imageEast = bbox[2];
    final imageWest = bbox[0];

    return AppTemplate(
      currentIndex: 1,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng((imageNorth + imageSouth) / 2, (imageEast + imageWest) / 2),
              initialZoom: 10.0,
              maxZoom: 18.0,
              minZoom: 3.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _getLayerUrl(),
                additionalOptions: {
                  'accessToken': mapboxToken,
                },
                subdomains: const ['a', 'b', 'c'],
                tileProvider: CancellableNetworkTileProvider(),
              ),
              OverlayImageLayer(
                overlayImages: [
                  OverlayImage(
                    bounds: LatLngBounds(
                      LatLng(imageSouth, imageWest),
                      LatLng(imageNorth, imageEast),
                    ),
                    imageProvider: NetworkImage(thumbnailUrl),
                  ),
                ],
              ),
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: [
                      LatLng(widget.south, widget.west),
                      LatLng(widget.south, widget.east),
                      LatLng(widget.north, widget.east),
                      LatLng(widget.north, widget.west),
                    ],
                    color: Colors.blue.withOpacity(0.3),
                    borderStrokeWidth: 2.0,
                    borderColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Column(
              children: [
                FloatingActionButton(
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
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {
                  _showLoadingDialog(context);
                  _analisarImagem(context);
                },
                child: const Text('Analisar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}