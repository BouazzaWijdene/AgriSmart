/**
 * Schémas de validation des endpoints d'authentification.
 * Chaque règle est consommée par le middleware `valider`.
 */
exports.inscription = {
  body: {
    email: { requis: true, type: 'email' },
    motDePasse: { requis: true, type: 'chaine', longueurMin: 8, longueurMax: 72 },
    nom: { requis: false, type: 'chaine', longueurMin: 1, longueurMax: 100 },
    prenom: { requis: false, type: 'chaine', longueurMin: 1, longueurMax: 100 },
  },
};

exports.connexion = {
  body: {
    email: { requis: true, type: 'email' },
    motDePasse: { requis: true, type: 'chaine', longueurMin: 1, longueurMax: 72 },
  },
};

exports.profil = {
  body: {
    nom: { requis: false, type: 'chaine', longueurMin: 1, longueurMax: 100 },
    prenom: { requis: false, type: 'chaine', longueurMin: 1, longueurMax: 100 },
  },
};

exports.motDePasse = {
  body: {
    ancienMotDePasse: { requis: true, type: 'chaine', longueurMin: 1, longueurMax: 72 },
    nouveauMotDePasse: { requis: true, type: 'chaine', longueurMin: 8, longueurMax: 72 },
  },
};

exports.motDePasseOublie = {
  body: {
    email: { requis: true, type: 'email' },
  },
};
