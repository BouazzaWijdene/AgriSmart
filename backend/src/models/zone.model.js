const { requete, uneLigne } = require('../config/database');

const COLONNES = 'id, utilisateur_id, nom, culture, superficie_ha, humidite, seuil, vanne_ouverte, cree_le, modifie_le';

/**
 * Projette une ligne SQL vers le format attendu par l'application Flutter
 * (clés identiques au `fromJson` de la classe Zone), enrichi de champs utiles.
 * NB : les colonnes NUMERIC arrivent en chaîne depuis pg → conversion Number.
 */
function versZoneApi(ligne) {
  const humidite = Number(ligne.humidite);
  const seuil = Number(ligne.seuil);
  const besoinIrrigation = humidite < seuil;

  return {
    id: ligne.id,
    nom: ligne.nom,
    culture: ligne.culture,
    superficieHa: ligne.superficie_ha === null ? null : Number(ligne.superficie_ha),
    humidite,
    seuil,
    vanneOuverte: ligne.vanne_ouverte,
    besoinIrrigation,
    diagnostic: besoinIrrigation ? "Besoin d'irrigation" : 'Sol correct',
    creeLe: ligne.cree_le,
    modifieLe: ligne.modifie_le,
  };
}

/** Liste toutes les zones d'un utilisateur (les siennes uniquement). */
async function listerParUtilisateur(utilisateurId) {
  const resultat = await requete(
    `SELECT ${COLONNES} FROM zones WHERE utilisateur_id = $1 ORDER BY cree_le ASC`,
    [utilisateurId],
  );
  return resultat.rows.map(versZoneApi);
}

/** Renvoie la zone si elle appartient bien à l'utilisateur, sinon null. */
async function trouverParIdEtUtilisateur(id, utilisateurId) {
  const ligne = await uneLigne(
    `SELECT ${COLONNES} FROM zones WHERE id = $1 AND utilisateur_id = $2`,
    [id, utilisateurId],
  );
  return ligne ? versZoneApi(ligne) : null;
}

async function creer(utilisateurId, zone) {
  const ligne = await uneLigne(
    `INSERT INTO zones (utilisateur_id, nom, culture, superficie_ha, humidite, seuil, vanne_ouverte)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING ${COLONNES}`,
    [
      utilisateurId,
      zone.nom,
      zone.culture,
      zone.superficieHa ?? null,
      zone.humidite,
      zone.seuil,
      zone.vanneOuverte ?? false,
    ],
  );
  return versZoneApi(ligne);
}

/** Mise à jour partielle : seuls les champs fournis sont modifiés. */
async function mettreAJour(id, utilisateurId, champs) {
  const sets = [];
  const valeurs = [];

  const ajouter = (colonne, valeur) => {
    valeurs.push(valeur);
    sets.push(`${colonne} = $${valeurs.length}`);
  };

  if (champs.nom !== undefined) ajouter('nom', champs.nom);
  if (champs.culture !== undefined) ajouter('culture', champs.culture);
  if (champs.superficieHa !== undefined) ajouter('superficie_ha', champs.superficieHa);
  if (champs.humidite !== undefined) ajouter('humidite', champs.humidite);
  if (champs.seuil !== undefined) ajouter('seuil', champs.seuil);
  if (champs.vanneOuverte !== undefined) ajouter('vanne_ouverte', champs.vanneOuverte);

  if (sets.length === 0) return trouverParIdEtUtilisateur(id, utilisateurId);

  valeurs.push(id, utilisateurId);
  const ligne = await uneLigne(
    `UPDATE zones SET ${sets.join(', ')}
     WHERE id = $${valeurs.length - 1} AND utilisateur_id = $${valeurs.length}
     RETURNING ${COLONNES}`,
    valeurs,
  );
  return ligne ? versZoneApi(ligne) : null;
}

async function supprimer(id, utilisateurId) {
  const resultat = await requete(
    'DELETE FROM zones WHERE id = $1 AND utilisateur_id = $2',
    [id, utilisateurId],
  );
  return resultat.rowCount > 0;
}

/** Ouvre ou referme la vanne d'irrigation d'une zone. */
async function definirVanne(id, utilisateurId, ouverte) {
  const ligne = await uneLigne(
    `UPDATE zones SET vanne_ouverte = $3
     WHERE id = $1 AND utilisateur_id = $2
     RETURNING ${COLONNES}`,
    [id, utilisateurId, ouverte],
  );
  return ligne ? versZoneApi(ligne) : null;
}

/** Statistiques agrégées du tableau de bord de l'utilisateur. */
async function statistiques(utilisateurId) {
  const ligne = await uneLigne(
    `SELECT
       COUNT(*)::int                                 AS nb_zones,
       COALESCE(AVG(humidite), 0)                    AS humidite_moyenne,
       COUNT(*) FILTER (WHERE humidite < seuil)::int AS nb_a_irriguer,
       COUNT(*) FILTER (WHERE vanne_ouverte)::int     AS nb_vannes_ouvertes,
       COALESCE(SUM(superficie_ha), 0)               AS superficie_totale
     FROM zones
     WHERE utilisateur_id = $1`,
    [utilisateurId],
  );

  const zonesAIrriguer = await requete(
    `SELECT id, nom, culture, humidite, seuil
     FROM zones
     WHERE utilisateur_id = $1 AND humidite < seuil
     ORDER BY humidite ASC`,
    [utilisateurId],
  );

  return {
    nbZones: ligne.nb_zones,
    humiditeMoyenne: Math.round(Number(ligne.humidite_moyenne) * 10) / 10,
    nbZonesAIrriguer: ligne.nb_a_irriguer,
    nbVannesOuvertes: ligne.nb_vannes_ouvertes,
    superficieTotaleHa: Number(ligne.superficie_totale),
    zonesAIrriguer: zonesAIrriguer.rows.map((z) => ({
      id: z.id,
      nom: z.nom,
      culture: z.culture,
      humidite: Number(z.humidite),
      seuil: Number(z.seuil),
    })),
  };
}

module.exports = {
  versZoneApi,
  listerParUtilisateur,
  trouverParIdEtUtilisateur,
  creer,
  mettreAJour,
  supprimer,
  definirVanne,
  statistiques,
};
