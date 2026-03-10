import 'package:flutter/material.dart';
import 'views/auth/login_screen.dart';

void main() {
  runApp(const CargolockApp());
}

class CargolockApp extends StatelessWidget {
  const CargolockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CargoLock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF001220), 
        scaffoldBackgroundColor: const Color(0xFF00050A),
        fontFamily: 'Roboto', 
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}