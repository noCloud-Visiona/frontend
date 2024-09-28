import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:frontend/pages/analisar_img_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/pages/user_profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'noCloud',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: const TextTheme(
            titleLarge: TextStyle(color: Colors.white),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Verifica se o auto-login pode ser feito
            return FutureBuilder(
              future: authProvider.tryAutoLogin(),
              builder: (context, authResultSnapshot) {
                // Se o usuário estiver logado, redirecionar para AnalisarImgPage
                if (authProvider.jwtToken != null) {
                  return const AnalisarImgPage(imgPath: '');
                }
                // Caso contrário, redirecionar para LoginPage
                return const LoginPage();
              },
            );
          },
        ),
        routes: {
          '/analisar': (context) => const AnalisarImgPage(imgPath: ''),
          '/perfil': (context) => const UserProfilePage(),
          '/login': (context) => const LoginPage(),
        },
      ),
    );
  }
}
