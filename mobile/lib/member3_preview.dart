import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'features/exchange_messaging_profile/screens/rate_review_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const Member3PreviewApp());
}

class Member3PreviewApp extends StatelessWidget {
  const Member3PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rent Lanka - Member 3 Preview',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Arial',
      ),
      home: const RateReviewScreen(
        equipmentId: 'demo_ss_cricket_bat',
        providerId: 'demo_provider_001',
        bookingId: 'demo_booking_001',
        equipmentName: 'SS Cricket Bat',
        rentedDate: '15 Sep',
      ),
    );
  }
}
