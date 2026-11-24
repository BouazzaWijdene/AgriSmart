const meteoService = require('../services/meteo.service');
const { ApiError } = require('../utils/ApiError');

// Coordonnées par défaut : mêmes que l'application Flutter (région de Sidi Bouzid).
const LATITUDE_DEFAUT = 33.70;
const LONGITUDE_DEFAUT = 8.97;

/**
 * GET /api/meteo?latitude=&longitude= — météo courante + prévisions 3 jours.
 * La réponse conserve le format Open-Meteo (`current` + `daily`) pour rester
 * compatible avec `Meteo.fromJson` côté Flutter.
 */
async function actuelle(requete, reponse) {
  const latitude = requete.query.latitude !== undefined
    ? Number(requete.query.latitude)
    : LATITUDE_DEFAUT;
  const longitude = requete.query.longitude !== undefined
    ? Number(requete.query.longitude)
    : LONGITUDE_DEFAUT;

  if (Number.isNaN(latitude) || latitude < -90 || latitude > 90) {
    throw new ApiError(422, 'latitude doit être un nombre entre -90 et 90.');
  }
  if (Number.isNaN(longitude) || longitude < -180 || longitude > 180) {
    throw new ApiError(422, 'longitude doit être un nombre entre -180 et 180.');
  }

  const donnees = await meteoService.obtenirMeteo(latitude, longitude);
  reponse.json(donnees);
}

module.exports = { actuelle };
