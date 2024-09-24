import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/pages/detalhe_imagem_page.dart';
import 'package:frontend/pages/template/app_template.dart';

class AnalisarImgPage extends StatelessWidget {
  final String imgPath;
  const AnalisarImgPage({super.key, required this.imgPath});

  @override
  Widget build(BuildContext context) {
    print(
        'Exibindo imagem em AnalisarImgPage com imgPath: $imgPath'); // Log para depuração

    return AppTemplate(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (kIsWeb)
              Image.network(
                imgPath,
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              )
            else
              Image.file(
                File(imgPath),
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetalheImgPage()),
                );
              },
              child: const Text('Analisar'),
            ),
          ],
        ),
      ),
      currentIndex: 1,
    );
  }
}
