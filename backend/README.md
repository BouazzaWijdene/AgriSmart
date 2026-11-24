# 🌱 Agrismart API — Backend Node.js + Express + PostgreSQL

API REST du projet **Agrismart** (application Flutter de gestion intelligente de l'irrigation
agricole). Elle expose les fonctionnalités de l'application : authentification, gestion des
zones de culture, relevés d'humidité, pilotage des vannes, météo et statistiques.

## 🧱 Stack technique

| Composant         | Choix                                        |
|-------------------|----------------------------------------------|
| Exécution         | Node.js ≥ 20 (ESM non requis, CommonJS)      |
| Framework HTTP    | Express 5                                    |
| Base de données   | PostgreSQL 14+ (pilote `pg`, pool partagé)   |
| Authentification  | JWT (HS256) + hachage bcrypt                  |
| Sécurité          | helmet, cors, express-rate-limit             |
| Logs              | morgan                                       |

## 📐 Architecture (séparation des responsabilités)

```
backend/
├── scripts/
│   └── setup-db.ps1            → création du rôle + base (1 seule fois)
├── src/
│   ├── server.js               → bootstrap, connexion DB, arrêt gracieux
│   ├── app.js                  → application Express (middlewares, routes)
│   ├── config/
│   │   ├── env.js              → configuration validée (l'unique lecture de process.env)
│   │   └── database.js         → pool PostgreSQL, transactions
│   ├── middleware/
│   │   ├── auth.js             → vérification JWT, rôles
│   │   ├── validate.js         → moteur de validation (body/query/params)
│   │   ├── errorHandler.js    → gestion centralisée (erreurs PG → HTTP)
│   │   └── notFound.js         → 404 JSON
│   ├── validators/             → schémas de validation par domaine
│   ├── models/                 → accès aux données (SQL paramétré uniquement)
│   ├── controllers/            → logique métier (aucun SQL ici)
│   ├── services/
│   │   └── meteo.service.js    → proxy Open-Meteo + cache mémoire 10 min
│   ├── routes/                 → déclaration des endpoints REST
│   ├── sql/
│   │   └── schema.sql          → DDL idempotent (tables, index, triggers)
│   └── scripts/
│       ├── init-db.js          → applique le schéma   (npm run db:init)
│       └── seed.js             → données de démo      (npm run db:seed)
├── .env                        → configuration locale (non versionné)
└── .env.example                → modèle de configuration
```

**Flux d'une requête** : `route` → `middleware (auth + validation)` → `controller`
→ `model (SQL)` → `réponse JSON`. Les erreurs remontent au gestionnaire central.

## ✅ Prérequis

- Node.js ≥ 20 et npm
- PostgreSQL 14+ en fonctionnement (local ou distant)

## 🚀 Démarrage rapide

```powershell
# 1. Créer le rôle + la base PostgreSQL (droits superutilisateur, une seule fois)
powershell -File scripts/setup-db.ps1 -MotDePasseSuperutilisateur '<votre_mdp_postgres>'

# 2. Installer les dépendances
cd backend
npm install

# 3. Créer les tables puis les données de démonstration
npm run db:init
npm run db:seed

# 4. Démarrer l'API (rechargement auto à chaque modification)
npm run dev
# → http://localhost:3000
```

## 📜 Scripts npm

| Commande           | Rôle                                              |
|--------------------|---------------------------------------------------|
| `npm run dev`      | Démarre en mode développement (`node --watch`)    |
| `npm start`        | Démarre en mode production                        |
| `npm run db:init`  | Applique `src/sql/schema.sql` (tables, index…)    |
| `npm run db:seed`  | Insère le compte démo + zones + relevés            |
| `npm run db:setup` | `db:init` + `db:seed` en une commande              |

## ⚙️ Configuration (`.env`)

Copiez `.env.example` vers `.env` puis ajustez :

| Variable             | Description                                  | Défaut                     |
|----------------------|----------------------------------------------|----------------------------|
| `PORT`               | Port d'écoute                                | `3000`                     |
| `NODE_ENV`           | `development` / `production`                | `development`              |
| `PGHOST` / `PGPORT`  | Hôte / port PostgreSQL                       | `localhost` / `5432`       |
| `PGUSER`             | Rôle applicatif                              | `agrismart`                |
| `PGPASSWORD`         | Mot de passe du rôle applicatif              | —                          |
| `PGDATABASE`         | Nom de la base                               | `agrismart`                |
| `JWT_SECRET`         | Secret JWT — **obligatoire en production** (≥ 32 car.) | valeur de dev   |
| `JWT_EXPIRES_IN`     | Durée de vie du jeton                        | `7d`                       |
| `CORS_ORIGIN`        | `*` ou liste d'origines séparées par virgules| `*`                        |
| `METEO_CACHE_TTL_MIN`| Durée du cache météo (minutes)               | `10`                       |

## 📚 Documentation de l'API

Toutes les réponses sont en JSON. Les endpoints protégés exigent l'en-tête :
`Authorization: Bearer <jeton>` (obtenu à l'inscription/connexion).

### Format des erreurs

```json
{
  "erreur": "Données invalides.",
  "details": ["email doit être une adresse e-mail valide."]
}
```

Codes utilisés : `400` requête invalide · `401` non authentifié · `403` interdit ·
`404` introuvable · `409` conflit (doublon) · `413` corps trop volumineux ·
`422` validation · `429` trop de tentatives · `502` service externe · `503` base indisponible.

### 🔐 Authentification — `/api/auth`

| Méthode | Route                    | Description                                     | Auth ? |
|---------|--------------------------|-------------------------------------------------|--------|
| POST    | `/inscription`           | Créer un compte (email + mot de passe ≥ 8 car.) | Non    |
| POST    | `/connexion`             | Se connecter → jeton JWT                        | Non    |
| POST    | `/mot-de-passe-oublie`  | Demande de réinitialisation (anti-énumération)  | Non    |
| GET     | `/moi`                   | Profil de l'utilisateur connecté                | Oui    |
| PUT     | `/profil`                | Modifier nom / prénom                           | Oui    |
| PUT     | `/mot-de-passe`          | Changer de mot de passe                          | Oui    |
| POST    | `/deconnexion`           | 204 — le jeton est jeté côté client             | Oui    |

**Inscription**
```powershell
curl.exe -X POST http://localhost:3000/api/auth/inscription `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"karim@example.com\",\"motDePasse\":\"MotDePasse1!\",\"nom\":\"Ben Salah\",\"prenom\":\"Karim\"}'
```
```json
{
  "utilisateur": {
    "id": "d0b1…", "uid": "d0b1…", "email": "karim@example.com",
    "nom": "Ben Salah", "prenom": "Karim", "role": "agriculteur", "creeLe": "…"
  },
  "token": "eyJhbGciOi…"
}
```

**Connexion**
```powershell
curl.exe -X POST http://localhost:3000/api/auth/connexion `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"demo@agrismart.com\",\"motDePasse\":\"Demo1234!\"}'
```

### 🌾 Zones de culture — `/api/zones` (protégé)

| Méthode | Route                    | Description                                        |
|---------|--------------------------|----------------------------------------------------|
| GET     | `/`                      | Liste des zones de l'utilisateur                   |
| POST    | `/`                      | Créer une zone                                     |
| GET     | `/:id`                   | Détail d'une zone                                  |
| PUT     | `/:id`                   | Mise à jour partielle                              |
| DELETE  | `/:id`                   | Supprimer la zone (+ son historique, cascade)      |
| PATCH   | `/:id/vanne`             | Ouvrir/fermer la vanne — body `{"ouverte": true}`  |
| POST    | `/:id/humidite`          | Enregistrer un relevé (body `{"humidite": 62.5}`)  |
| GET     | `/:id/historique?jours=7`| Relevés récents                                    |

**Créer une zone**
```powershell
curl.exe -X POST http://localhost:3000/api/zones `
  -H "Authorization: Bearer <jeton>" -H "Content-Type: application/json" `
  -d '{\"nom\":\"Parcelle Nord\",\"culture\":\"Tomates\",\"humidite\":58,\"seuil\":40,\"superficieHa\":2.5}'
```
```json
{
  "id": "3f9c…", "nom": "Parcelle Nord", "culture": "Tomates",
  "superficieHa": 2.5, "humidite": 58, "seuil": 40, "vanneOuverte": false,
  "besoinIrrigation": false, "diagnostic": "Sol correct", "creeLe": "…", "modifieLe": "…"
}
```

> 💡 Les clés (`nom`, `culture`, `humidite`, `seuil`, `vanneOuverte`) sont **identiques au
> `fromJson` de la classe Flutter `Zone`** : la désérialisation côté mobile est immédiate.

> 🧠 **Irrigation intelligente** : lors d'un relevé (`POST /:id/humidite`), si l'humidité
> atteint le seuil, la vanne est **refermée automatiquement** (transaction atomique).

### 🌤️ Météo — `GET /api/meteo?latitude=&longitude=` (protégé)

Proxy serveur vers Open-Meteo, avec **cache mémoire de 10 min** (une seule requête
extérieure pour tous les clients). Coordonnées par défaut : `33.70, 8.97` (comme l'app).

La réponse conserve le format Open-Meteo (`current` + `daily`) : `Meteo.fromJson`
côté Flutter fonctionne sans modification.

```powershell
curl.exe "http://localhost:3000/api/meteo" -H "Authorization: Bearer <jeton>"
```

### 📊 Statistiques — `GET /api/stats` (protégé)

Tableau de bord de l'utilisateur : nombre de zones, humidité moyenne, zones à irriguer,
vannes ouvertes, superficie totale, liste des zones à irriguer.

```json
{
  "nbZones": 4, "humiditeMoyenne": 52, "nbZonesAIrriguer": 2,
  "nbVannesOuvertes": 0, "superficieTotaleHa": 6.0,
  "zonesAIrriguer": [
    { "id": "…", "nom": "Parcelle Ouest", "culture": "Poivrons", "humidite": 35, "seuil": 45 },
    { "id": "…", "nom": "Parcelle Sud", "culture": "Carottes", "humidite": 45, "seuil": 50 }
  ]
}
```

### ❤️ Santé — `GET /api/sante` (public)

```json
{ "statut": "ok", "base": "connectée", "environnement": "development", "disponibiliteSecondes": 42, "version": "1.0.0" }
```

## 🗄️ Schéma de la base de données

| Table               | Rôle | Points clés |
|---------------------|------|-------------|
| `utilisateurs`      | Comptes | UUID PK, `email` unique, hash bcrypt, rôle check, `modifie_le` mis à jour par trigger |
| `zones`             | Zones de culture | FK `utilisateur_id` **CASCADE**, humidité/seuil contraints 0–100, `UNIQUE(utilisateur_id, nom)` |
| `releves_humidite`  | Historique | FK `zone_id` **CASCADE**, index `(zone_id, enregistre_le DESC)` |

Isolation des données : **toutes** les requêtes de zones filtrent par
`utilisateur_id` issu du JWT — un utilisateur ne voit jamais les zones d'un autre.

## 🔒 Sécurité

- **Mots de passe** : hachés avec bcrypt (10 rounds), jamais sérialisés dans les réponses.
- **JWT** : secret configurable, expiration configurable, messages distincts (expiré / invalide).
- **Anti-énumération** : connexion et mot-de-passe-oublié renvoient des messages neutres.
- **Anti brute-force** : 20 requêtes / 15 min / IP sur `/api/auth/*` (rate limiting).
- **Injection SQL** : requêtes 100 % paramétrées (`$1, $2…`), concaténation interdite.
- **En-têtes** : `helmet` (HSTS, nosniff, frameguard…), CORS configurable.
- **Fuites** : en production, les erreurs 500 n'exposent pas les détails internes.

## 📱 Intégration avec l'application Flutter

L'API a été conçue pour coller aux modèles existants (`Zone.fromJson`,
`Meteo.fromJson`, `Utilisateur`) :

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AgrismartApi {
  static const baseUrl = 'http://10.0.2.2:3000'; // émulateur Android → machine hôte
  final String? token;

  Future<List<Zone>> chargerZones() async {
    final reponse = await http.get(
      Uri.parse('$baseUrl/api/zones'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (reponse.statusCode != 200) {
      throw Exception('Erreur API (${reponse.statusCode})');
    }

    return (jsonDecode(reponse.body) as List)
        .map((z) => Zone.fromJson(Map<String, dynamic>.from(z)))
        .toList();
  }
}
```

> ⚠️ Pour un appareil physique, remplacez `10.0.2.2` par l'IP locale de la machine
> qui héberge l'API, et utilisez `http` uniquement en développement.

## 👤 Compte de démonstration

Après `npm run db:seed` :

```
E-mail        : demo@agrismart.com
Mot de passe  : Demo1234!
Zones         : Parcelle Nord (Tomates), Sud (Carottes), Est (Persil), Ouest (Poivrons)
```

## 🗺️ Idées d'évolution

- Refresh tokens + révocation serveur (liste noire Redis)
- Service SMTP pour la réinitialisation de mot de passe
- Endpoints `/api/admin/*` (middleware `rolesAutorises('admin')` déjà prêt)
- Notifications push quand une zone passe sous son seuil
- Tests automatisés (supertest + base de test jetable)


