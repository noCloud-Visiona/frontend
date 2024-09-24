import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
        if (index == 1) {
          final ImagePicker picker = ImagePicker();
          final XFile? image =
              await picker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            print('Imagem Selecionada: ${image.path}');
            onTap(index,
                image.path); // Passa o caminho da imagem para a função onTap
          } else {
            onTap(index, null); // Passa null se nenhuma imagem for selecionada
          }
        } else {
          onTap(index, null); // Passa null para outros índices
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
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
    );
  }
}
