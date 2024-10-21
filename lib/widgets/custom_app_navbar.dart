import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/utils/jwt_utils.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/user_profile_page.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onUserIconPressed;
  final bool shouldCheckJwt;

  const CustomNavBar({
    super.key,
    this.onBackPressed,
    this.onUserIconPressed,
    this.shouldCheckJwt = true,
  });

  void _checkJwtAndRedirect(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.jwtToken;

    if (token == null || !isTokenValid(token)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sessão Expirada'),
              content: const Text('Sua sessão expirou, por favor, faça login novamente.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (shouldCheckJwt) {
      _checkJwtAndRedirect(context);
    }

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
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final token = authProvider.jwtToken;
            String userInitial = '';

            if (token != null && isTokenValid(token)) {
              final tokenPayload = getDecodedToken(token);
              final userName = tokenPayload?['nome'];
              if (userName != null && userName.isNotEmpty) {
                userInitial = userName[0].toUpperCase();
              }
            }

            return IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userInitial, // Exibe a inicial do nome
                  style: const TextStyle(color: Color(0xFF176B87)),
                ),
              ),
              onPressed: () {
                if (token == null || !isTokenValid(token)) {
                  return; // Não faz nada se não houver token
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfilePage()),
                );
              },
            );
          },
        ),
      ],
      toolbarHeight: 60.0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
