import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 5),
          content,
        ],
      ),
      actions: actions,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/images/noCloud_logo_transparente_1.png',
            height: 120,
            width: 100,
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF176B87)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}