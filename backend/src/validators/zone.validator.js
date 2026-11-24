/**
 * Schémas de validation des endpoints « zones » et « relevés ».
 */
exports.creation = {
  body: {
    nom: { requis: true, type: 'chaine', longueurMin: 1, longueurMax: 100 },
    culture: { requis: true, type: 'chaine', longueurMin: 1, longueurMax: 100 },
    humidite: { requis: true, type: 'nombre', min: 0, max: 100 },
    seuil: { requis: true, type: 'nombre', min: 0, max: 100 },
    superficieHa: { requis: false, type: 'nombre', min: 0.01, max: 100000 },
    vanneOuverte: { requis: false, type: 'booleen' },
  },
};

exports.miseAJour = {
  body: {
    nom: { requis: false, type: 'chaine', longueurMin: 1, longueurMax: 100 },
    culture: { requis: false, type: 'chaine', longueurMin: 1, longueurMax: 100 },
    humidite: { requis: false, type: 'nombre', min: 0, max: 100 },
    seuil: { requis: false, type: 'nombre', min: 0, max: 100 },
    superficieHa: { requis: false, type: 'nombre', min: 0.01, max: 100000 },
    vanneOuverte: { requis: false, type: 'booleen' },
  },
};

exports.humidite = {
  body: {
    humidite: { requis: true, type: 'nombre', min: 0, max: 100 },
  },
};

exports.vanne = {
  body: {
    ouverte: { requis: true, type: 'booleen' },
  },
};

exports.historique = {
  query: {
    jours: { requis: false, type: 'entier', min: 1, max: 90 },
  },
};
