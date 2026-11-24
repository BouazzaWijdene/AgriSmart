/**
 * Charge et valide la configuration depuis l'environnement (.env).
 * Toute la configuration de l'application passe par ce module :
 * aucun module ne lit directement process.env ailleurs.
 */
require('dotenv').config({ quiet: true }); // « quiet » : pas de message « injected env » à chaque démarrage

const env = process.env;

const config = {
  nodeEnv: env.NODE_ENV || 'development',
  port: Number.parseInt(env.PORT || '3000', 10),

  pg: {
    host: env.PGHOST || 'localhost',
    port: Number.parseInt(env.PGPORT || '5432', 10),
    utilisateur: env.PGUSER || 'agrismart',
    motDePasse: env.PGPASSWORD || '',
    base: env.PGDATABASE || 'agrismart',
  },

  jwt: {
    secret: env.JWT_SECRET || 'secret_developpement_a_changer_absolument',
    duree: env.JWT_EXPIRES_IN || '7d',
  },

  corsOrigines: env.CORS_ORIGIN || '*',

  meteo: {
    url: env.METEO_URL || 'https://api.open-meteo.com/v1/forecast',
    cacheTtlMin: Number.parseInt(env.METEO_CACHE_TTL_MIN || '10', 10),
  },
};

// Garde-fou : on refuse de démarrer en production avec un secret faible.
if (config.nodeEnv === 'production' && config.jwt.secret.length < 32) {
  throw new Error(
    'JWT_SECRET est obligatoire en production (minimum 32 caractères).',
  );
}

module.exports = config;
