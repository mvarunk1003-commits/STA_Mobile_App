import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appProvider = AppProvider();
  await appProvider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const SstpaApp(),
    ),
  );
}

class SstpaApp extends StatelessWidget {
  const SstpaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return MaterialApp(
      title: 'STPA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo.shade800,
          secondary: Colors.amber.shade700,
          surface: Colors.grey.shade50,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo.shade900,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: provider.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
