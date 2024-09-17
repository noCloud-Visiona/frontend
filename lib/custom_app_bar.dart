import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onUserIconPressed;

  CustomAppBar({
    required this.title,
    this.onBackPressed,
    this.onUserIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF176B87),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed,
      ),
      title: Center(
        child: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white), // Novo ícone de usuário
          onPressed: onUserIconPressed,
        ),
      ],
      // Ajuste o espaçamento do título centralizado
      toolbarHeight: 60.0, // Ajuste o valor conforme necessário
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
