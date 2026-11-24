const config = require('../config/env');
const { ApiError } = require('../utils/ApiError');

/**
 * Proxy serveur vers l'API Open-Meteo.
 * Avantages : l'URL/la clé restent côté serveur, une seule requête extérieure
 * pour tous les clients, et un cache mémoire évite de marteler le service.
 */
const cache = new Map();

const cleDeCache = (latitude, longitude) =>
  `${latitude.toFixed(2)}|${longitude.toFixed(2)}`;

/** Nettoie les entrées expirées pour éviter toute fuite mémoire. */
function nettoyerCache(now) {
  for (const [cle, entree] of cache) {
    if (entree.expiration <= now) cache.delete(cle);
  }
}

/**
 * Renvoie la météo (format identique à Open-Meteo : `current` + `daily`)
 * pour que l'application Flutter puisse réutiliser `Meteo.fromJson` telle quelle.
 * @param {number} latitude  entre -90 et 90
 * @param {number} longitude entre -180 et 180
 */
async function obtenirMeteo(latitude, longitude) {
  const maintenant = Date.now();
  const cle = cleDeCache(latitude, longitude);

  const enCache = cache.get(cle);
  if (enCache && enCache.expiration > maintenant) {
    return enCache.donnees;
  }

  const url = new URL(config.meteo.url);
  url.searchParams.set('latitude', String(latitude));
  url.searchParams.set('longitude', String(longitude));
  url.searchParams.set('current', 'temperature_2m,relative_humidity_2m,wind_speed_10m');
  url.searchParams.set('daily', 'temperature_2m_max,temperature_2m_min,precipitation_sum');
  url.searchParams.set('timezone', 'auto');
  url.searchParams.set('forecast_days', '3');

  let reponse;
  try {
    reponse = await fetch(url, { signal: AbortSignal.timeout(10_000) });
  } catch (_erreur) {
    throw new ApiError(502, 'Le service météo est injoignable, réessayez plus tard.');
  }

  if (!reponse.ok) {
    throw new ApiError(502, `Erreur du service météo (HTTP ${reponse.status}).`);
  }

  const donnees = await reponse.json();
  donnees.generePar = 'Agrismart API (source : Open-Meteo)';

  nettoyerCache(maintenant);
  cache.set(cle, {
    donnees,
    expiration: maintenant + config.meteo.cacheTtlMin * 60_000,
  });

  return donnees;
}

module.exports = { obtenirMeteo };
