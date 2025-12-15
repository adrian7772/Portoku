import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'pages/auth_gate.dart';
import 'state/app_state_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PortokuApp());
}

class PortokuApp extends StatelessWidget {
  const PortokuApp({super.key});

  static const navy = Color(0xFF0A1A2F);
  static const navy2 = Color(0xFF0F2A54);
  static const accent = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: navy,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: navy2,
        background: navy,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      // ✅ Material 3 NavigationBar (recommended)
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: navy2,
        indicatorColor: Color(0xFF163A73),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(size: 24),
        ),
      ),

      // ✅ kalau kamu pakai BottomNavigationBar (opsional aman)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: navy2,
        selectedItemColor: accent,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Portoku',
      theme: theme,
      home: const AppStateRoot(
        child: AuthGate(),
      ),
    );
  }
}
