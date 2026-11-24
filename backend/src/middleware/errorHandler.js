const config = require('../config/env');
const { ApiError } = require('../utils/ApiError');

/**
 * Traduit une erreur PostgreSQL (code SQLSTATE) en ApiError HTTP cohérente.
 * Renvoie null si l'erreur ne vient pas de la base.
 */
function traduireErreurPg(erreur) {
  switch (erreur.code) {
    case '23505': { // unique_violation
      if (erreur.constraint === 'utilisateurs_email_key') {
        return new ApiError(409, 'Un compte existe déjà avec cet e-mail.');
      }
      if (erreur.constraint === 'zones_utilisateur_id_nom_key') {
        return new ApiError(409, 'Une zone portant ce nom existe déjà.');
      }
      return new ApiError(409, 'Cette ressource existe déjà.');
    }
    case '23503': // foreign_key_violation
      return new ApiError(409, 'Ressource liée introuvable.');
    case '23514': // check_violation
      return new ApiError(400, 'Une contrainte de validité des données a été violée.');
    case '23502': // not_null_violation
      return new ApiError(400, 'Un champ obligatoire est manquant.');
    case '22P02': // invalid_text_representation (ex. UUID malformé)
      return new ApiError(400, 'Identifiant invalide (UUID attendu).');
    default:
      // Classe 08xxx = erreurs de connexion / identifiants / base indisponible.
      const codesConnexion = [
        'ECONNREFUSED', 'ETIMEDOUT', 'ENOTFOUND', 'EAI_AGAIN',
        '28P01', // mot de passe invalide
        '28000', // rôle inexistant / identifiants refusés
        '3D000', // base inexistante
        '57P01', '57P02', '57P03',
      ];
      if (erreur.code?.startsWith('08') || codesConnexion.includes(erreur.code)) {
        return new ApiError(
          503,
          'Base de données indisponible (vérifiez la configuration .env et le service PostgreSQL).',
        );
      }
      return null;
  }
}

/** Gestionnaire d'erreurs central : format de réponse JSON uniforme. */
function gestionnaireErreurs(erreur, requete, reponse, _suite) {
  // Erreurs applicatives explicites
  if (erreur instanceof ApiError) {
    return reponse.status(erreur.statut).json({
      erreur: erreur.message,
      ...(erreur.details ? { details: erreur.details } : {}),
    });
  }

  // Erreurs d'analyse du corps de requête (express.json)
  if (erreur.type === 'entity.parse.failed') {
    return reponse.status(400).json({ erreur: 'Corps de requête JSON invalide.' });
  }
  if (erreur.type === 'entity.too.large') {
    return reponse.status(413).json({ erreur: 'Corps de requête trop volumineux.' });
  }

  // Erreurs PostgreSQL
  const erreurPg = traduireErreurPg(erreur);
  if (erreurPg) {
    console.error(`[DB] ${erreur.code} : ${erreur.message}`);
    return reponse.status(erreurPg.statut).json({
      erreur: erreurPg.message,
      ...(erreurPg.details ? { details: erreurPg.details } : {}),
    });
  }

  // Erreur inattendue : log complet côté serveur, message filtré en production
  console.error('[API] Erreur interne :', erreur);
  return reponse.status(500).json({
    erreur: config.nodeEnv === 'production'
      ? 'Erreur interne du serveur.'
      : `Erreur interne : ${erreur.message}`,
  });
}

module.exports = { gestionnaireErreurs };
