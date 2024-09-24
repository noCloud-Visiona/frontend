import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/pages/analisar_img_page.dart';
import 'package:frontend/widgets/custom_app_bottombar.dart';
import 'package:frontend/widgets/custom_app_navbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path; // Adicione esta linha

class AppTemplate extends StatelessWidget {
  final Widget body;
  final int currentIndex;

  const AppTemplate({
    super.key,
    required this.body,
    required this.currentIndex,
  });

  Future<String> saveImage(String imagePath) async {
    if (kIsWeb) {
      // No Flutter Web, apenas retorne o caminho da imagem
      return imagePath;
    } else {
      // No Android/iOS, copie a imagem para o diretório de documentos
      final directory = await getApplicationDocumentsDirectory();
      final String newPath = path.join(directory.path, path.basename(imagePath));

      final File imageFile = File(imagePath);
      await imageFile.copy(newPath);

      print('Imagem salva: $newPath'); // Log para depuração

      return newPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavBar(
        onBackPressed: () {
          Navigator.pop(context);
        },
        onUserIconPressed: () {
          // Ação para o ícone de usuário
        },
      ),
      body: body,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex, // Índice da página atual
        onTap: (index, imagePath) async {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1 && imagePath != null) {
            try {
              String savedImagePath = await saveImage(imagePath);
              print('Navegando para AnalisarImgPage com imgPath: $savedImagePath'); // Log para depuração
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalisarImgPage(imgPath: savedImagePath),
                ),
              );
            } catch (e) {
              print('Erro ao salvar a imagem: $e'); // Log para depuração
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao salvar a imagem: $e')),
              );
            }
          } else if (index == 2) {
            Navigator.pushNamed(context, '/lista');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image, color: Colors.white),
            label: 'Imagem',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.white),
            label: 'Lista',
          ),
        ],
      ),
    );
  }
}