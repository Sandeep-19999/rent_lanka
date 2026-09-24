import 'package:flutter/material.dart';
import 'screens/provider/provider_dashboard.dart';

void main() {
  runApp(const RentLankaApp());
}

class RentLankaApp extends StatelessWidget {
  const RentLankaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rent Lanka',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F8FA),
        fontFamily: 'Arial',
      ),
      home: const ProviderDashboard(),
    );
  }
}