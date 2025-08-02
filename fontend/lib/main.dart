import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_manager/screens/tabs.dart';
import 'package:task_manager/screens/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 8, 8, 8),
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token');
  
  runApp(MaterialApp(
    theme: theme,
    home: token == null ? const LoginScreen() : const TabsScreen(),
  ));
}