import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/resultado_busca.dart';
import 'package:frontend/pages/template/app_template.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:frontend/utils/search_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  DateTime? _startDate;
  DateTime? _endDate;
  LatLng? _startPoint;
  LatLng? _endPoint;
  bool _isDrawing = false;

  void _onDateRangeSelected(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      print('Data de início ou fim é nula');
      return;
    }
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
    });
  }

  bool _isFormValid() {
    return _startDate != null &&
        _endDate != null &&
        _startPoint != null &&
        _endPoint != null;
  }

  void _startDrawing() {
    setState(() {
      _isDrawing = !_isDrawing;
      if (!_isDrawing) {
        _startPoint = null;
        _endPoint = null;
      }
    });
  }

  void _onTap(TapPosition tapPosition, LatLng point) {
    if (_isDrawing) {
      setState(() {
        if (_startPoint == null) {
          _startPoint = point;
        } else {
          _endPoint = point;
          _isDrawing = false;
        }
      });
    }
  }

  Future<void> _fetchDataFromINPE(DateTime startDate, DateTime endDate,
      LatLng startPoint, LatLng endPoint) async {
    final String startDateString = startDate.toIso8601String().split('T').first;
    final String endDateString = endDate.toIso8601String().split('T').first;
    final String bbox =
        '${startPoint.longitude},${startPoint.latitude},${endPoint.longitude},${endPoint.latitude}';
    final String url =
        'https://data.inpe.br/bdc/stac/v1/search?collections=CBERS4-WFI-16D-2&datetime=$startDateString/$endDateString&bbox=$bbox';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultadoBuscaPage(
              startDate: startDate,
              endDate: endDate,
              startPoint: startPoint,
              endPoint: endPoint,
              features: features,
            ),
          ),
        );
      } else {
        print('Erro na solicitação: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na solicitação: $e');
    }
  }

  void _onSearchButtonPressed() {
    if (_isFormValid()) {
      _fetchDataFromINPE(_startDate!, _endDate!, _startPoint!, _endPoint!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, selecione as datas e uma área no mapa antes de realizar a busca.'),
        ),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return AppTemplate(
      currentIndex: 0,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                  -14.2350, -51.9253), // Coordenadas centrais do Brasil
              initialZoom: _zoomLevel,
              maxZoom: 18.0,
              minZoom: 3.0,
              onTap: _onTap,
            ),
            children: [
              TileLayer(
                urlTemplate: _getLayerUrl(),
                additionalOptions: {
                  'accessToken': _mapboxToken,
                },
                subdomains: const ['a', 'b', 'c'],
                tileProvider: CancellableNetworkTileProvider(),
              ),
              if (_startPoint != null && _endPoint != null)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: [
                        _startPoint!,
                        LatLng(_startPoint!.latitude, _endPoint!.longitude),
                        _endPoint!,
                        LatLng(_endPoint!.latitude, _startPoint!.longitude),
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
            left: 10,
            top: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateRangeSelector(onDateRangeSelected: _onDateRangeSelected),
              ],
            ),
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
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'drawButton',
                  onPressed: _startDrawing,
                  mini: true,
                  backgroundColor:
                      _isDrawing ? const Color(0xFF176B87) : Colors.white,
                  foregroundColor:
                      _isDrawing ? Colors.white : const Color(0xFF176B87),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color:
                          _isDrawing ? Colors.white : const Color(0xFF176B87),
                      width: 1,
                    ),
                  ),
                  child: const Icon(Icons.crop_square),
                ),
              ],
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
                    side: const BorderSide(color: Color(0xFF176B87), width: 1),
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
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              width: 66,
              height: 66,
              child: FloatingActionButton(
                heroTag: 'searchButton',
                onPressed: _onSearchButtonPressed,
                mini: false,
                foregroundColor: const Color(0xFF176B87),
                backgroundColor: const Color(0xFFB4D4FF),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(
                      color: Colors.white, width: 1), // Adiciona a borda de 1px
                ),
                child: const Icon(
                  Icons.search,
                  size: 42,
                  weight: 1000,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
}

extension on MapController {
  LatLng get initialCenter => LatLng(-14.2350, -51.9253);
}