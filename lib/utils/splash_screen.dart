import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Solicitar permissões de armazenamento
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    // Verificar se a permissão foi concedida
    if (status.isGranted) {
      // Navegar para a tela principal após conceder a permissão
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Exibir mensagem de erro se a permissão não for concedida
      bool? openSettings = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permissão Necessária'),
            content: const Text(
                'Este aplicativo precisa de acesso ao armazenamento para baixar arquivos. Deseja permitir o acesso?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Não'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sim'),
              ),
            ],
          );
        },
      );

      if (openSettings == true) {
        await openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}