
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:projet/config.dart';
import 'package:projet/firebase_options.dart';
import 'package:projet/providers/auth_provider.dart';
import 'package:projet/providers/zones_provider.dart';
import 'package:projet/providers/meteo_provider.dart';
import 'package:projet/providers/reglages_provider.dart';
import 'package:projet/screens/auth_gate.dart';
import 'package:projet/service/auth_locale_service.dart';
import 'package:projet/service/auth_service.dart';
import 'package:projet/service/firebase_auth_service.dart';
import 'package:projet/theme/app_them.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthService authService;

  if (utiliserFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    authService = FirebaseAuthService();
  } else {
    authService = AuthLocaleService();
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider(
          create: (context) => ZonesProvider(
            prefs,
            context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MeteoProvider(prefs)..charger(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReglagesProvider(prefs),
        ),
      ],
      child: const AgriSmartApp(),
    ),
  );
}

class AgriSmartApp extends StatelessWidget {
  const AgriSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriSmart',
      theme: AppTheme.clair(),
      darkTheme: AppTheme.sombre(),
      themeMode: context.watch<ReglagesProvider>().themeMode,
      home: const AuthGate(),
    );
  }
}
