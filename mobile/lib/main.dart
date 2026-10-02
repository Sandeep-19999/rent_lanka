// import 'package:flutter/material.dart';
// import 'screens/provider/provider_dashboard.dart';

// void main() {
//   runApp(const RentLankaApp());
// }

// class RentLankaApp extends StatelessWidget {
//   const RentLankaApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Rent Lanka',
//       theme: ThemeData(
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(0xFFF8F8FA),
//         fontFamily: 'Arial',
//       ),
//       home: const ProviderDashboard(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
// import 'screens/provider/provider_dashboard.dart';
import 'screens/user_discovery/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      home: const SplashScreen(),
    );
  }
}