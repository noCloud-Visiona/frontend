import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onUserIconPressed;

  const CustomNavBar({
    super.key, 
    this.onBackPressed,
    this.onUserIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF176B87),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed,
      ),
      title: const Center(
        child: Text(
          'noCloud',
          style: TextStyle(color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white), // Novo ícone de usuário
          onPressed: onUserIconPressed,
        ),
      ],
      // Ajuste o espaçamento do título centralizado
      toolbarHeight: 60.0, // Ajuste o valor conforme necessário
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
