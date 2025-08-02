// lib/main.dart
import 'package:flutter/material.dart';
import 'package:kumapan_mobile/screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // runApp(const MyApp());
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
      home: LoginScreen(), // Halaman pertama yang dibuka adalah Login
    );
  }
}
