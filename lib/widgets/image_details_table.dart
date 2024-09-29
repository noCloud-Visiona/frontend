import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_img_detail_table.dart';

class ImageDetailsTable extends StatelessWidget {
  final Map<String, dynamic> data;

  const ImageDetailsTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomTable(
      data: [
        {'campo': 'ID', 'valor': data['id'] ?? ''},
        {'campo': 'Data', 'valor': data['data'] ?? ''},
        {'campo': 'Hora', 'valor': data['hora'] ?? ''},
        {'campo': 'Resolução da Imagem', 'valor': data['resolucao_imagem'] ?? ''},
        {'campo': 'Satélite', 'valor': data['satelite'] ?? ''},
        {'campo': 'Sensor', 'valor': data['sensor'] ?? ''},
        {'campo': 'Percentual de Nuvem', 'valor': '${data['percentual_nuvem'] ?? ''}%'},
        {'campo': 'Área Visível no Mapa', 'valor': '${data['area_visivel_mapa'] ?? ''}%'},
      ],
    );
  }
}