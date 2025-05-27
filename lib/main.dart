import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'telas/login_tela.dart';
import 'telas/home_tela.dart';
import 'telas/doacao_tela.dart';
import 'firebase_options.dart'; // Gerado automaticamente
import 'telas/cadastro_tela.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ShareNowApp());
}

class ShareNowApp extends StatelessWidget {
  const ShareNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareNow',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/cadastro': (context) => CadastroTela(),
        '/home': (context) => HomeScreen(),
        '/doacao': (context) => DoacaoTela(),
      },
    );
  }
}