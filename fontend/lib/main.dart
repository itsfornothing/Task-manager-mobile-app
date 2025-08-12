import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_manager/screens/noti_service.dart';
import 'package:task_manager/screens/tabs.dart';
import 'package:task_manager/screens/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/provider/profile_provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NotiService().initNotification();
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token');

  runApp(ProviderScope(child: App(token: token)));
}

class App extends ConsumerWidget {
  final String? token;
  const App({super.key, this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(bgProvider);

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        seedColor: const Color.fromARGB(255, 8, 8, 8),
      ),
      textTheme: GoogleFonts.latoTextTheme(),
    );

    return MaterialApp(
      theme: theme,
      home: token == null ? const LoginScreen() : const TabsScreen(),
    );
  }
}
