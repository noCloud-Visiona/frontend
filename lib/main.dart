import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import necessário
import 'package:provider/provider.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/analisar_img_page.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        home: const LoginPage(),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale('pt', 'BR'), // Adiciona suporte para português do Brasil
        ],
        routes: {
          '/analisar': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            return AnalisarImgPage(
              imgPath: args['imgPath'],
            );
          },
          '/login': (context) => const LoginPage(),
        },
      ),
    );
  }
}