import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet/providers/auth_provider.dart';
import 'package:projet/screens/app_shell.dart';
import 'package:projet/screens/connexion_page.dart';

// Choisit l'écran selon l'état d'authentification.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.initialise) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!auth.connecte) {
      return const ConnexionPage();
    }

    return const AppShell();
  }
}
