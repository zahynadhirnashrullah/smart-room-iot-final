import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // --- KHUSUS WEB (BROWSER) ---
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          // ============================================================
          // TUGAS ANDA: Buka Firebase Console -> Project Settings -> General -> Scroll ke bawah (Web App)
          // Salin data "firebaseConfig" dan tempel di sini:
          // ============================================================
          apiKey: "AIzaSyB5H-max3ZPP1YcayPxWDzGnQADY2YZtvo",
          appId: "room-monitoring-d1a4f",
          messagingSenderId: "358289377382",

          // --- BAGIAN INI SUDAH SAYA ISIKAN (Berdasarkan kode ESP32 Anda) ---
          projectId: "room-monitoring-d1a4f",
          databaseURL:
              "https://room-monitoring-d1a4f-default-rtdb.asia-southeast1.firebasedatabase.app",
          storageBucket: "room-monitoring-d1a4f.appspot.com",
        ),
      );
    } else {
      // --- KHUSUS ANDROID (HP) ---
      // Otomatis membaca file android/app/google-services.json
      await Firebase.initializeApp();
    }
  } catch (e) {
    // JIKA ERROR, TAMPILKAN DI CONSOLE TAPI JANGAN BIKIN MACET
    print("------------------------------------------------");
    print("FATAL ERROR: Gagal Koneksi Firebase: $e");
    print("------------------------------------------------");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Room IoT',
      debugShowCheckedModeBanner:
          false, // Menghilangkan pita 'Debug' di pojok kanan
      theme: ThemeData(fontFamily: 'Roboto', useMaterial3: true),
      // --- BAGIAN INI SUDAH DIGANTI KE SPLASH SCREEN ---
      home: const SplashScreen(),
    );
  }
}
