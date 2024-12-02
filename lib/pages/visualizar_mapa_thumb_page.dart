import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:frontend/pages/template/app_template.dart';

class VisualizarMapaThumb extends StatefulWidget {
  final Map<String, dynamic> featureData;

  const VisualizarMapaThumb({
    Key? key,
    required this.featureData,
  }) : super(key: key);

  @override
  _VisualizarMapaThumbState createState() => _VisualizarMapaThumbState();
}

class _VisualizarMapaThumbState extends State<VisualizarMapaThumb> {
  final MapController _mapController = MapController();
  String _currentLayer = 'hybrid';
  List<String> _selectedThumbnails = [];

  final Map<String, String> _thumbnails = {};

  @override
  void initState() {
    super.initState();
    _thumbnails['Imagem Original'] = widget.featureData['identificacao_ia']['thumbnail_imagem_url'];
    _thumbnails['Nuvem'] = widget.featureData['identificacao_ia']['thumbnail_nuvem_url'];
    _thumbnails['Sombra'] = widget.featureData['identificacao_ia']['thumbnail_sombra_url'];
    _thumbnails['Imagem Processada'] = widget.featureData['identificacao_ia']['img_tratada'];
    _thumbnails['Sem Nuvem'] = widget.featureData['identificacao_ia']['thumbnail_sem_nuvem_url'];
    _thumbnails['Sem Sombra'] = widget.featureData['identificacao_ia']['thumbnail_sem_sombra_url'];
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

  void _toggleThumbnail(String key) {
    setState(() {
      if (_selectedThumbnails.contains(key)) {
        _selectedThumbnails.remove(key);
      } else {
        _selectedThumbnails.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String mapboxToken = dotenv.env["MAPBOX_TOKEN"] ?? '';

    // Extrair dados do JSON
    final bbox = widget.featureData['bbox'];

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
              initialCenter: LatLng(
                  (imageNorth + imageSouth) / 2, (imageEast + imageWest) / 2),
              initialZoom: 6.0,
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
              for (String key in _selectedThumbnails)
                OverlayImageLayer(
                  overlayImages: [
                    OverlayImage(
                      bounds: LatLngBounds(
                        LatLng(imageSouth, imageWest),
                        LatLng(imageNorth, imageEast),
                      ),
                      imageProvider: NetworkImage(_thumbnails[key]!),
                      opacity: 1.0, // Remover a transparência
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
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'thumbnailButton',
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
                    icon: const Icon(Icons.image),
                    itemBuilder: (BuildContext context) {
                      return _thumbnails.keys.map((String key) {
                        return PopupMenuItem<String>(
                          value: key,
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return CheckboxListTile(
                                title: Text(key),
                                value: _selectedThumbnails.contains(key),
                                activeColor: const Color(0xFF176B87), // Cor ativa do checkbox
                                checkColor: Colors.white, // Cor do ícone de seleção
                                onChanged: (bool? value) {
                                  setState(() {
                                    _toggleThumbnail(key);
                                  });
                                },
                              );
                            },
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}