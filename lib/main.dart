import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // --- KHUSUS WEB (BROWSER) ---
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyB5H-max3ZPP1YcayPxWDzGnQADY2YZtvo",
          appId: "room-monitoring-d1a4f",
          messagingSenderId: "358289377382",
          projectId: "room-monitoring-d1a4f",
          databaseURL:
              "https://room-monitoring-d1a4f-default-rtdb.asia-southeast1.firebasedatabase.app",
          storageBucket: "room-monitoring-d1a4f.appspot.com",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    print("FATAL ERROR: Gagal Koneksi Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Room IoT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto', useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
