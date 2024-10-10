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
    this.shouldCheckJwt = true, // Por padrão, o shouldCheckJwt é true, e desativado apenas na page login_page e register_page.
  });

  void _checkJwtAndRedirect(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.jwtToken;

    // Verifica se o token está presente e se é válido
    if (token == null || !isTokenValid(token)) {
      // Exibe o popup avisando que o login expirou
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
                    Navigator.of(context).pop(); // Fecha o dialog
                    // Redireciona para a página de login
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
    // Verifica o JWT apenas se o parâmetro shouldCheckJwt for true
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
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {
            // Verifica o JWT antes de executar a ação do ícone do usuário
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final token = authProvider.jwtToken;

            // Se o token for nulo ou inválido, não faz nada
            if (token == null || !isTokenValid(token)) {
              return; // Não faz nada se não houver token
            }

            // Se o token for válido, execute a ação desejada
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            );
          },
        ),
      ],
      toolbarHeight: 60.0, // Ajuste o valor conforme necessário
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
