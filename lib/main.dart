import 'package:flutter/foundation.dart'; // Import para usar kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/pages/analisar_img_page.dart';
import 'package:frontend/pages/history_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/utils/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';

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
        ChangeNotifierProvider(
          create: (_) => AuthProvider(), // Adicione seu AuthProvider aqui
        ),
      ],
      child: MaterialApp(
        title: 'noCloud',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: const TextTheme(
            titleLarge: TextStyle(color: Colors.white),
          ),
        ),
        home: _getInitialPage(), // Definir a página inicial dinamicamente
        routes: {
          '/analisar': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return AnalisarImgPage(
              imgPath: args['imgPath'],
            );
          },
          '/login': (context) => const LoginPage(),
          '/lista': (context) => HistoricoPage(),
        },
      ),
    );
  }

  // Função para decidir qual tela inicial carregar
  Widget _getInitialPage() {
    if (kIsWeb) {
      // Se for uma aplicação web, vai diretamente para a LoginPage
      return const LoginPage();
    } else {
      // Se for um dispositivo móvel, abre a SplashScreen
      return const SplashScreen();
    }
  }
}
