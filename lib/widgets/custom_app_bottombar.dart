import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/pages/home_page.dart'; 

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int, String?) onTap;
  final List<BottomNavigationBarItem> items;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF176B87),
      currentIndex: currentIndex,
      onTap: (index) async {
        if (index == 0) {
          // Navegar para a HomePage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (index == 1) {
          final ImagePicker picker = ImagePicker();
          final XFile? image =
              await picker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            print('Imagem Selecionada: ${image.path}');
            onTap(index,
                image.path); 
          } else {
            onTap(index, null); 
          }
        } else {
          onTap(index, null); 
        }
      },
      items: items,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
    );
  }
}