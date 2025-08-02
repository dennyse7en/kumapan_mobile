// lib/main.dart
import 'package:flutter/material.dart';
import 'package:kumapan_mobile/screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Firebase

  initializeDateFormatting('id_ID', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kumapan',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      // Selalu mulai dari LoginScreen
      home: LoginScreen(),
    );
  }
}
