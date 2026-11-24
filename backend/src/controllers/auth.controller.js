const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../config/env');
const utilisateurModel = require('../models/utilisateur.model');
const { genererJeton } = require('../utils/jeton');
const { ApiError } = require('../utils/ApiError');

// Coût de hachage bcrypt : bon compromis sécurité / latence pour un usage web.
const ROUNDS_BCRYPT = 10;

const normaliserEmail = (email) => String(email).trim().toLowerCase();

/** POST /api/auth/inscription — crée un compte et renvoie le jeton. */
async function inscription(requete, reponse) {
  const { email, motDePasse, nom, prenom } = requete.body;

  const existant = await utilisateurModel.trouverParEmail(normaliserEmail(email));
  if (existant) {
    throw new ApiError(409, 'Un compte existe déjà avec cet e-mail.');
  }

  const motDePasseHash = await bcrypt.hash(motDePasse, ROUNDS_BCRYPT);
  const utilisateur = await utilisateurModel.creer({
    email: normaliserEmail(email),
    motDePasse: motDePasseHash,
    nom: nom?.trim(),
    prenom: prenom?.trim(),
  });

  reponse.status(201).json({
    utilisateur: utilisateurModel.versUtilisateurApi(utilisateur),
    token: genererJeton(utilisateur),
  });
}

/** POST /api/auth/connexion — vérifie les identifiants et délivre un jeton. */
async function connexion(requete, reponse) {
  const { email, motDePasse } = requete.body;

  const utilisateur = await utilisateurModel.trouverParEmail(normaliserEmail(email));
  const motDePasseOk = utilisateur
    && (await bcrypt.compare(motDePasse, utilisateur.mot_de_passe));

  // Message volontairement identique dans tous les cas d'échec (anti-énumération).
  if (!motDePasseOk) {
    throw new ApiError(401, 'E-mail ou mot de passe incorrect.');
  }

  reponse.json({
    utilisateur: utilisateurModel.versUtilisateurApi(utilisateur),
    token: genererJeton(utilisateur),
  });
}

/** GET /api/auth/moi — profil de l'utilisateur authentifié. */
async function moi(requete, reponse) {
  const utilisateur = await utilisateurModel.trouverParId(requete.utilisateur.id);
  if (!utilisateur) throw new ApiError(401, 'Compte introuvable.');
  reponse.json({ utilisateur: utilisateurModel.versUtilisateurApi(utilisateur) });
}

/** PUT /api/auth/profil — mise à jour du nom / prénom. */
async function majProfil(requete, reponse) {
  const { nom, prenom } = requete.body;
  const utilisateur = await utilisateurModel.mettreAJourProfil(requete.utilisateur.id, {
    nom: nom !== undefined ? nom.trim() : undefined,
    prenom: prenom !== undefined ? prenom.trim() : undefined,
  });
  reponse.json({ utilisateur: utilisateurModel.versUtilisateurApi(utilisateur) });
}

/** PUT /api/auth/mot-de-passe — changement de mot de passe (ancien requis). */
async function majMotDePasse(requete, reponse) {
  const { ancienMotDePasse, nouveauMotDePasse } = requete.body;

  const utilisateur = await utilisateurModel.trouverParId(requete.utilisateur.id);
  const ancienOk = utilisateur
    && (await bcrypt.compare(ancienMotDePasse, utilisateur.mot_de_passe));

  if (!ancienOk) throw new ApiError(401, 'Ancien mot de passe incorrect.');

  const motDePasseHash = await bcrypt.hash(nouveauMotDePasse, ROUNDS_BCRYPT);
  await utilisateurModel.mettreAJourMotDePasse(utilisateur.id, motDePasseHash);

  reponse.json({ message: 'Mot de passe mis à jour avec succès.' });
}

/**
 * POST /api/auth/mot-de-passe-oublie — demande de réinitialisation.
 * La réponse est identique que le compte existe ou non (anti-énumération).
 * Sans service SMTP branché, un jeton temporaire est renvoyé en développement.
 */
async function motDePasseOublie(requete, reponse) {
  const { email } = requete.body;
  const utilisateur = await utilisateurModel.trouverParEmail(normaliserEmail(email));

  const corps = {
    message: 'Si un compte existe pour cet e-mail, un lien de réinitialisation a été envoyé.',
  };

  if (utilisateur && config.nodeEnv !== 'production') {
    corps.jetonDev = jwt.sign(
      { finalite: 'reinitialisation' },
      config.jwt.secret,
      { subject: utilisateur.id, expiresIn: '15m' },
    );
  }

  reponse.json(corps);
}

/**
 * POST /api/auth/deconnexion — l'API est sans état (JWT) : la déconnexion
 * consiste à supprimer le jeton côté client.
 */
async function deconnexion(_requete, reponse) {
  reponse.status(204).send();
}

module.exports = {
  inscription,
  connexion,
  moi,
  majProfil,
  majMotDePasse,
  motDePasseOublie,
  deconnexion,
};
