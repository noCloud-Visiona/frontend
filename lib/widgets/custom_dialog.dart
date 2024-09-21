import 'package:flutter/material.dart';

void showCustomDialog(BuildContext context, String message, VoidCallback? onOk) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
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
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Roboto',
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF009D42),
            ),
            child: const Text(
              "Ok",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (onOk != null) {
                onOk(); // Chama o callback se não for nulo
              }
            },
          ),
        ],
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
              icon: Icon(Icons.close, color: const Color(0xFF176B87)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
