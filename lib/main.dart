import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Muat data terperinci dari local storage sebelum UI dimulai
  await StorageService.initData();

  runApp(const WaliSongoApp());
}

class WaliSongoApp extends StatefulWidget {
  const WaliSongoApp({super.key});

  @override
  State<WaliSongoApp> createState() => _WaliSongoAppState();
}

class _WaliSongoAppState extends State<WaliSongoApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wali Songo EduApp',
      theme: ThemeData(
        useMaterial3: true,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        colorSchemeSeed: const Color(0xFF0077B6),
      ),
      home: LoginScreen(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: () => setState(() => _isDarkMode = !_isDarkMode),
      ),
    );
  }
}
