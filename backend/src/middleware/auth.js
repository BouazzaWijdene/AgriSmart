const { ApiError } = require('../utils/ApiError');
const { verifierJeton } = require('../utils/jeton');

/**
 * Exige un JWT valide (en-tête « Authorization: Bearer <jeton> »)
 * et attache l'utilisateur authentifié à req.utilisateur.
 */
function authentifie(requete, _reponse, suite) {
  const entete = requete.headers.authorization;

  if (!entete || !entete.startsWith('Bearer ')) {
    throw new ApiError(
      401,
      "Jeton d'authentification manquant (en-tête Authorization: Bearer requis).",
    );
  }

  try {
    const charge = verifierJeton(entete.slice('Bearer '.length).trim());
    requete.utilisateur = { id: charge.sub, email: charge.email, role: charge.role };
    suite();
  } catch (erreur) {
    if (erreur.name === 'TokenExpiredError') {
      throw new ApiError(401, 'Jeton expiré, veuillez vous reconnecter.');
    }
    throw new ApiError(401, 'Jeton invalide.');
  }
}

/**
 * Restreint l'accès à certains rôles.
 * Ex. : routes.get('/', authentifie, rolesAutorises('admin'), controleur…)
 */
function rolesAutorises(...roles) {
  return (requete, _reponse, suite) => {
    if (!requete.utilisateur || !roles.includes(requete.utilisateur.role)) {
      throw new ApiError(403, "Vous n'avez pas les droits nécessaires pour cette action.");
    }
    suite();
  };
}

module.exports = { authentifie, rolesAutorises };
