import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_app_bottombar.dart';
import 'package:frontend/widgets/custom_app_navbar.dart';

class AppTemplate extends StatelessWidget {
  final Widget body;
  final int currentIndex;

  const AppTemplate({
    super.key,
    required this.body,
    required this.currentIndex,
  });

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
        onTap: (index) {
          // Navegação para outras páginas
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/upload');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/lista');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Imagem',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
        ],
      ),
    );
  }
}