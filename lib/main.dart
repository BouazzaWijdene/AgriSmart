
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet/providers/meteo_provider.dart';
import 'package:projet/config.dart';
import 'package:projet/firebase_options.dart';
import 'package:projet/providers/auth_provider.dart';
import 'package:projet/providers/zones_provider.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ZonesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MeteoProvider(),
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
      title: 'AGRISMART',
      theme: AppTheme.clair(),
      darkTheme: AppTheme.sombre(),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}
