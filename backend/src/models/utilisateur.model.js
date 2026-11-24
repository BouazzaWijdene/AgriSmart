const { requete, uneLigne } = require('../config/database');

const COLONNES = 'id, email, mot_de_passe, nom, prenom, role, cree_le, modifie_le';

/**
 * Projette une ligne SQL vers l'objet public exposé par l'API.
 * ⚠ Le hash du mot de passe n'est JAMAIS sérialisé.
 */
function versUtilisateurApi(ligne) {
  return {
    id: ligne.id,
    uid: ligne.id, // compatibilité avec le modèle `Utilisateur` de l'app Flutter
    email: ligne.email,
    nom: ligne.nom,
    prenom: ligne.prenom,
    role: ligne.role,
    creeLe: ligne.cree_le,
    modifieLe: ligne.modifie_le,
  };
}

async function trouverParEmail(email) {
  return uneLigne(`SELECT ${COLONNES} FROM utilisateurs WHERE email = $1`, [email]);
}

async function trouverParId(id) {
  return uneLigne(`SELECT ${COLONNES} FROM utilisateurs WHERE id = $1`, [id]);
}

async function creer({ email, motDePasse, nom, prenom }) {
  return uneLigne(
    `INSERT INTO utilisateurs (email, mot_de_passe, nom, prenom)
     VALUES ($1, $2, $3, $4)
     RETURNING ${COLONNES}`,
    [email, motDePasse, nom ?? null, prenom ?? null],
  );
}

/** Mise à jour partielle du profil (uniquement les champs fournis). */
async function mettreAJourProfil(id, { nom, prenom }) {
  const sets = [];
  const valeurs = [];

  if (nom !== undefined) { valeurs.push(nom); sets.push(`nom = $${valeurs.length}`); }
  if (prenom !== undefined) { valeurs.push(prenom); sets.push(`prenom = $${valeurs.length}`); }

  if (sets.length === 0) return trouverParId(id);

  valeurs.push(id);
  return uneLigne(
    `UPDATE utilisateurs SET ${sets.join(', ')}
     WHERE id = $${valeurs.length}
     RETURNING ${COLONNES}`,
    valeurs,
  );
}

async function mettreAJourMotDePasse(id, motDePasseHash) {
  return uneLigne(
    `UPDATE utilisateurs SET mot_de_passe = $2 WHERE id = $1 RETURNING ${COLONNES}`,
    [id, motDePasseHash],
  );
}

async function compter() {
  const resultat = await requete('SELECT COUNT(*)::int AS total FROM utilisateurs');
  return resultat.rows[0].total;
}

module.exports = {
  versUtilisateurApi,
  trouverParEmail,
  trouverParId,
  creer,
  mettreAJourProfil,
  mettreAJourMotDePasse,
  compter,
};
