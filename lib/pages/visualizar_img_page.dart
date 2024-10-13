import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:frontend/pages/template/app_template.dart';

class VisualizarImagemPage extends StatelessWidget {
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

  Future<void> _analisarImagem(BuildContext context) async {
    try {
      // Criar o JSON com os dados da imagem e as coordenadas do usuário
      var requestData = {
        "type": featureData["type"],
        "id": featureData["id"],
        "collection": featureData["collection"],
        "stac_version": featureData["stac_version"],
        "stac_extensions": featureData["stac_extensions"],
        "geometry": featureData["geometry"],
        "links": featureData["links"],
        "bbox": featureData["bbox"],
        "assets": featureData["assets"],
        "properties": featureData["properties"],
        "user_geometry": {
          "type": "Polygon",
          "coordinates": [
            [
              [west, south],
              [west, north],
              [east, north],
              [east, south],
              [west, south]
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

  @override
  Widget build(BuildContext context) {
    final String mapboxToken = dotenv.env["MAPBOX_TOKEN"] ?? '';
    final MapController mapController = MapController();

    // Extrair dados do JSON
    final bbox = featureData['bbox'];
    final thumbnailUrl = featureData['assets']['thumbnail']['href'];

    final imageNorth = bbox[3];
    final imageSouth = bbox[1];
    final imageEast = bbox[2];
    final imageWest = bbox[0];

    return AppTemplate(
      currentIndex: 1,
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng((imageNorth + imageSouth) / 2, (imageEast + imageWest) / 2),
              initialZoom: 10.0,
              maxZoom: 18.0,
              minZoom: 3.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v11/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken&language=pt-BR',
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
                      LatLng(south, west),
                      LatLng(south, east),
                      LatLng(north, east),
                      LatLng(north, west),
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
                    onSelected: (layer) {
                      // Lógica para mudar a camada do mapa
                    },
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