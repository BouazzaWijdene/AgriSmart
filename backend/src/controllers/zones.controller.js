const zoneModel = require('../models/zone.model');
const releveModel = require('../models/releve.model');
const { ApiError } = require('../utils/ApiError');

/** Conversions défensives (le validateur a déjà garanti les types). */
const enNombre = (valeur) => (typeof valeur === 'number' ? valeur : Number(String(valeur).trim()));
const enBooleen = (valeur) => {
  if (typeof valeur === 'boolean') return valeur;
  return String(valeur) === 'true' || String(valeur) === '1';
};

/** GET /api/zones — liste des zones de l'utilisateur authentifié. */
async function lister(requete, reponse) {
  const zones = await zoneModel.listerParUtilisateur(requete.utilisateur.id);
  reponse.json(zones);
}

/** GET /api/zones/:id — détail d'une zone (si elle appartient à l'utilisateur). */
async function detail(requete, reponse) {
  const zone = await zoneModel.trouverParIdEtUtilisateur(requete.params.id, requete.utilisateur.id);
  if (!zone) throw new ApiError(404, 'Zone introuvable.');
  reponse.json(zone);
}

/** POST /api/zones — création d'une zone. */
async function creer(requete, reponse) {
  const corps = requete.body;

  const zone = await zoneModel.creer(requete.utilisateur.id, {
    nom: corps.nom.trim(),
    culture: corps.culture.trim(),
    superficieHa: corps.superficieHa !== undefined ? enNombre(corps.superficieHa) : undefined,
    humidite: enNombre(corps.humidite),
    seuil: enNombre(corps.seuil),
    vanneOuverte: corps.vanneOuverte !== undefined ? enBooleen(corps.vanneOuverte) : false,
  });

  reponse.status(201).json(zone);
}

/** PUT /api/zones/:id — mise à jour partielle d'une zone. */
async function mettreAJour(requete, reponse) {
  const corps = requete.body;
  const champs = {};

  if (corps.nom !== undefined) champs.nom = corps.nom.trim();
  if (corps.culture !== undefined) champs.culture = corps.culture.trim();
  if (corps.superficieHa !== undefined) champs.superficieHa = enNombre(corps.superficieHa);
  if (corps.humidite !== undefined) champs.humidite = enNombre(corps.humidite);
  if (corps.seuil !== undefined) champs.seuil = enNombre(corps.seuil);
  if (corps.vanneOuverte !== undefined) champs.vanneOuverte = enBooleen(corps.vanneOuverte);

  const zone = await zoneModel.mettreAJour(requete.params.id, requete.utilisateur.id, champs);
  if (!zone) throw new ApiError(404, 'Zone introuvable.');

  reponse.json(zone);
}

/** DELETE /api/zones/:id — suppression d'une zone. */
async function supprimer(requete, reponse) {
  const supprimee = await zoneModel.supprimer(requete.params.id, requete.utilisateur.id);
  if (!supprimee) throw new ApiError(404, 'Zone introuvable.');
  reponse.status(204).send();
}

/** PATCH /api/zones/:id/vanne — ouvre ou referme la vanne d'irrigation. */
async function basculerVanne(requete, reponse) {
  const zone = await zoneModel.definirVanne(
    requete.params.id,
    requete.utilisateur.id,
    enBooleen(requete.body.ouverte),
  );
  if (!zone) throw new ApiError(404, 'Zone introuvable.');
  reponse.json(zone);
}

/**
 * POST /api/zones/:id/humidite — enregistre un relevé d'humidité.
 * La zone est mise à jour dans la même transaction ; si le relevé atteint
 * le seuil, la vanne est refermée automatiquement (irrigation intelligente).
 */
async function enregistrerHumidite(requete, reponse) {
  const zone = await releveModel.enregistrer(
    requete.params.id,
    requete.utilisateur.id,
    enNombre(requete.body.humidite),
  );
  if (!zone) throw new ApiError(404, 'Zone introuvable.');
  reponse.status(201).json(zone);
}

/** GET /api/zones/:id/historique?jours=7 — relevés récents d'une zone. */
async function historique(requete, reponse) {
  const zone = await zoneModel.trouverParIdEtUtilisateur(requete.params.id, requete.utilisateur.id);
  if (!zone) throw new ApiError(404, 'Zone introuvable.');

  const jours = requete.query.jours !== undefined ? enNombre(requete.query.jours) : 7;
  const releves = await releveModel.listerParZone(zone.id, jours);
  reponse.json(releves);
}

module.exports = {
  lister,
  detail,
  creer,
  mettreAJour,
  supprimer,
  basculerVanne,
  enregistrerHumidite,
  historique,
};
