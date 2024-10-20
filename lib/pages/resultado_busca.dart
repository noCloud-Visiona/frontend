import 'package:flutter/material.dart';
import 'package:frontend/pages/analisar_img_INPE_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend/pages/template/app_template.dart'; // Importar o template

class ResultadoBuscaPage extends StatefulWidget {
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
  _ResultadoBuscaPageState createState() => _ResultadoBuscaPageState();
}

class _ResultadoBuscaPageState extends State<ResultadoBuscaPage> {
  List<dynamic> features = [];
  int totalImages = 0;
  int currentPage = 1;
  int itemsPerPage = kIsWeb ? 50 : 10;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    features = widget.features;
    startDate = widget.startDate;
    endDate = widget.endDate;
    fetchFeatures();
  }

  Future<void> fetchFeatures() async {
    final String startDateStr =
        startDate?.toIso8601String().split('T').first ?? '';
    final String endDateStr = endDate?.toIso8601String().split('T').first ?? '';
    final double minLat = widget.startPoint.latitude < widget.endPoint.latitude
        ? widget.startPoint.latitude
        : widget.endPoint.latitude;
    final double maxLat = widget.startPoint.latitude > widget.endPoint.latitude
        ? widget.startPoint.latitude
        : widget.endPoint.latitude;
    final double minLon =
        widget.startPoint.longitude < widget.endPoint.longitude
            ? widget.startPoint.longitude
            : widget.endPoint.longitude;
    final double maxLon =
        widget.startPoint.longitude > widget.endPoint.longitude
            ? widget.startPoint.longitude
            : widget.endPoint.longitude;

    final response = await http.get(Uri.parse(
        'https://data.inpe.br/bdc/stac/v1/search?collections=CBERS4-WFI-16D-2&datetime=$startDateStr/$endDateStr&bbox=$minLon,$minLat,$maxLon,$maxLat&limit=$itemsPerPage&page=$currentPage'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        features = data['features'];
        totalImages = data['context']['matched'];
      });
    } else {
      throw Exception('Failed to load features');
    }
  }

  Future<Map<String, dynamic>> fetchFeatureById(String id) async {
    final response = await http.get(Uri.parse(
        'https://data.inpe.br/bdc/stac/v1/collections/CBERS4-WFI-16D-2/items/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load feature');
    }
  }

  void nextPage() {
    setState(() {
      currentPage++;
      fetchFeatures();
    });
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        fetchFeatures();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calcular as coordenadas Norte, Sul, Leste e Oeste
    final double north = widget.startPoint.latitude > widget.endPoint.latitude
        ? widget.startPoint.latitude
        : widget.endPoint.latitude;
    final double south = widget.startPoint.latitude < widget.endPoint.latitude
        ? widget.startPoint.latitude
        : widget.endPoint.latitude;
    final double west = widget.startPoint.longitude < widget.endPoint.longitude
        ? widget.startPoint.longitude
        : widget.endPoint.longitude;
    final double east = widget.startPoint.longitude > widget.endPoint.longitude
        ? widget.startPoint.longitude
        : widget.endPoint.longitude;

    // Formatar as datas no formato pt-BR
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
    final String formattedStartDate =
        dateFormat.format(startDate ?? widget.startDate);
    final String formattedEndDate =
        dateFormat.format(endDate ?? widget.endDate);

    // Formatar as coordenadas com 4 casas decimais
    final String formattedNorth = north.toStringAsFixed(4);
    final String formattedSouth = south.toStringAsFixed(4);
    final String formattedWest = west.toStringAsFixed(4);
    final String formattedEast = east.toStringAsFixed(4);

    return AppTemplate(
      currentIndex: 0,
      body: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Resultados da Pesquisa'),
              Text(
                'Total de Imagens: $totalImages',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
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
                  Center(
                    child: Text('NORTE: $formattedNorth',
                        style: const TextStyle(fontSize: 16)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('OESTE: $formattedWest',
                          style: const TextStyle(fontSize: 16)),
                      Text('LESTE: $formattedEast',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  Center(
                    child: Text('SUL: $formattedSouth',
                        style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 2),
            Expanded(
              child: features.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: features.length,
                      itemBuilder: (context, index) {
                        final feature = features[index];
                        final id = feature['id'];
                        final thumbnailUrl =
                            feature['assets']['thumbnail']['href'];
                        final datetime = feature['properties']['datetime'];

                        // Formatar a data de observação
                        final DateTime observationDate =
                            DateTime.parse(datetime);
                        final String formattedObservationDate =
                            dateFormat.format(observationDate);

                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            child: ListTile(
                              leading: Image.network(thumbnailUrl),
                              title: Text('ID: $id'),
                              subtitle: Text(
                                  'Data de Observação: $formattedObservationDate'),
                              onTap: () async {
                                final featureData = await fetchFeatureById(id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnalisarImgINPEpage(
                                      id: id,
                                      thumbnailUrl: thumbnailUrl,
                                      datetime: formattedObservationDate,
                                      north: north,
                                      south: south,
                                      east: east,
                                      west: west,
                                      featureData: featureData,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 1 ? previousPage : null,
                  child: const Text('Página Anterior'),
                ),
                ElevatedButton(
                  onPressed: features.length == itemsPerPage ? nextPage : null,
                  child: const Text('Próxima Página'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
