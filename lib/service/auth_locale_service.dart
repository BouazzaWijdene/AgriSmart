
import 'dart:async';
import 'package:projet/models/utilisateur.dart';
import 'package:projet/service/auth_service.dart';

class AuthLocaleService implements AuthService {
  final Map<String, String> _comptes = {
    'demo@agrismart.tn': '123456'
  };

  final StreamController<Utilisateur?> _controller =
  StreamController<Utilisateur?>.broadcast();

  Utilisateur? _courant;

  @override
  Stream<Utilisateur?> get utilisateur async* {
    yield _courant;
    yield* _controller.stream;
  }

  @override
  Future<void> connexion(String email, String motDePasse) async {
    final e = email.trim();

    if (_comptes[e] != motDePasse) {
      throw const AuthException('Email ou mot de passe incorrect');
    }

    _courant = Utilisateur(uid: e, email: e);
    _controller.add(_courant);
  }

  @override
  Future<void> inscription(String email, String motDePasse) async {
    final e = email.trim();

    if (_comptes.containsKey(e)) {
      throw const AuthException('Un compte existe déjà avec cet email');
    }

    if (motDePasse.length < 6) {
      throw const AuthException('Mot de passe trop faible');
    }

    _comptes[e] = motDePasse;
    _courant = Utilisateur(uid: e, email: e);
    _controller.add(_courant);
  }

  @override
  Future<void> reinitialiserMotDePasse(String email) async {
    if (!_comptes.containsKey(email.trim())) {
      throw const AuthException('Email introuvable');
    }
  }

  @override
  Future<void> deconnexion() async {
    _courant = null;
    _controller.add(null);
  }
}
