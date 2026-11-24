const { ApiError } = require('../utils/ApiError');

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/** Une valeur est considérée absente si undefined, null ou chaîne vide. */
function estPresente(valeur) {
  return valeur !== undefined && valeur !== null && String(valeur).trim() !== '';
}

/** Valide une valeur selon une règle et renvoie la liste des erreurs. */
function validerValeur(champ, valeur, regle) {
  const erreurs = [];

  if (!estPresente(valeur)) {
    if (regle.requis) erreurs.push(`${champ} est obligatoire.`);
    return erreurs;
  }

  switch (regle.type) {
    case 'chaine': {
      if (typeof valeur !== 'string') {
        erreurs.push(`${champ} doit être une chaîne de caractères.`);
        break;
      }
      const longueur = valeur.trim().length;
      if (regle.longueurMin !== undefined && longueur < regle.longueurMin) {
        erreurs.push(`${champ} doit contenir au moins ${regle.longueurMin} caractère(s).`);
      }
      if (regle.longueurMax !== undefined && longueur > regle.longueurMax) {
        erreurs.push(`${champ} ne doit pas dépasser ${regle.longueurMax} caractère(s).`);
      }
      break;
    }
    case 'email': {
      if (typeof valeur !== 'string' || !EMAIL_REGEX.test(valeur.trim())) {
        erreurs.push(`${champ} doit être une adresse e-mail valide.`);
      }
      break;
    }
    case 'nombre': {
      const nombre = typeof valeur === 'number' ? valeur : Number(String(valeur).trim());
      if (Number.isNaN(nombre)) {
        erreurs.push(`${champ} doit être un nombre.`);
        break;
      }
      if (regle.min !== undefined && nombre < regle.min) {
        erreurs.push(`${champ} doit être supérieur ou égal à ${regle.min}.`);
      }
      if (regle.max !== undefined && nombre > regle.max) {
        erreurs.push(`${champ} doit être inférieur ou égal à ${regle.max}.`);
      }
      break;
    }
    case 'entier': {
      const entier = Number(String(valeur).trim());
      if (!Number.isInteger(entier)) {
        erreurs.push(`${champ} doit être un entier.`);
        break;
      }
      if (regle.min !== undefined && entier < regle.min) {
        erreurs.push(`${champ} doit être supérieur ou égal à ${regle.min}.`);
      }
      if (regle.max !== undefined && entier > regle.max) {
        erreurs.push(`${champ} doit être inférieur ou égal à ${regle.max}.`);
      }
      break;
    }
    case 'booleen': {
      if (typeof valeur !== 'boolean' && !['true', 'false', '1', '0'].includes(String(valeur))) {
        erreurs.push(`${champ} doit être un booléen (true ou false).`);
      }
      break;
    }
    default:
      break;
  }

  return erreurs;
}

/**
 * Génère un middleware de validation à partir d'un schéma :
 *   { body?: { champ: regle }, query?: { ... }, params?: { ... } }
 * Renvoie 422 avec la liste exhaustive des erreurs si la requête est invalide.
 */
function valider(schema) {
  return (requete, _reponse, suite) => {
    const erreurs = [];

    for (const [source, regles] of Object.entries(schema)) {
      const cible = source === 'body'
        ? requete.body
        : source === 'query'
          ? requete.query
          : requete.params;

      for (const [champ, regle] of Object.entries(regles)) {
        erreurs.push(...validerValeur(champ, cible?.[champ], regle));
      }
    }

    if (erreurs.length > 0) {
      throw new ApiError(422, 'Données invalides.', erreurs);
    }
    suite();
  };
}

module.exports = { valider };
