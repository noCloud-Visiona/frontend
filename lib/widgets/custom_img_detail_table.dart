import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  final List<Map<String, String>> data;

  const CustomTable({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        },
        border: TableBorder.all(color: Colors.black),
        children: [
          const TableRow(children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Campo', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Valor', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]),
          for (var row in data)
            TableRow(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(row['campo'] ?? ''),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(row['valor'] ?? ''),
              ),
            ]),
        ],
      ),
    );
  }
}