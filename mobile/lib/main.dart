import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/provider/provider_dashboard.dart';
import 'screens/booking/equipment_details_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RentLankaApp());
}

class RentLankaApp extends StatelessWidget {
  const RentLankaApp({super.key});

  static const bool bookingPreview = bool.fromEnvironment(
    'BOOKING_PREVIEW',
    defaultValue: false,
  );

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
      home: bookingPreview
          ? const EquipmentDetailsScreen()
          : const ProviderDashboard(),
    );
  }
}