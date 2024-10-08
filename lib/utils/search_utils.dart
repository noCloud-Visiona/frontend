import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSelector extends StatefulWidget {
  final Function(DateTime, DateTime) onDateRangeSelected;

  const DateRangeSelector({Key? key, required this.onDateRangeSelected})
      : super(key: key);

  @override
  _DateRangeSelectorState createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  DateTime? _startDate;
  DateTime? _endDate;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'), // Define o locale para português do Brasil
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      widget.onDateRangeSelected(_startDate!, _endDate!);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'), // Define o locale para português do Brasil
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      widget.onDateRangeSelected(_startDate!, _endDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF176B87),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                  color: Color(0xFF176B87),
                  width: 1), // Adiciona a borda de 1px
            ),
          ),
          onPressed: () => _selectStartDate(context),
          child: Text(_startDate == null
              ? 'Data Início'
              : _dateFormat.format(_startDate!)), // Formata a data no padrão brasileiro
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF176B87),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                  color: Color(0xFF176B87),
                  width: 1), // Adiciona a borda de 1px
            ),
          ),
          onPressed: () => _selectEndDate(context),
          child: Text(_endDate == null
              ? 'Data Final'
              : _dateFormat.format(_endDate!)), // Formata a data no padrão brasileiro
        ),
      ],
    );
  }
}