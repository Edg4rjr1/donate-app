import 'package:flutter/material.dart';
import 'telas/login_tela.dart';
import 'telas/home_tela.dart';
import 'telas/doacao_tela.dart';

void main() {
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
        '/home': (context) => HomeScreen(),
        '/doacao': (context) => DoacaoTela(),

      },
    );
  }
}