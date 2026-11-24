const express = require('express');
const config = require('../config/env');
const { testerConnexion } = require('../config/database');

const routeur = express.Router();

routeur.use('/auth', require('./auth.routes'));
routeur.use('/zones', require('./zones.routes'));
routeur.use('/meteo', require('./meteo.routes'));
routeur.use('/stats', require('./stats.routes'));

/**
 * GET /api/sante — sonde de santé publique (monitoring, uptime checks).
 * Ne nécessite pas d'authentification.
 */
routeur.get('/sante', async (_requete, reponse) => {
  let base = 'connectée';
  try {
    await testerConnexion();
  } catch (_erreur) {
    base = 'indisponible';
  }

  reponse.json({
    statut: 'ok',
    base,
    environnement: config.nodeEnv,
    disponibiliteSecondes: Math.round(process.uptime()),
    version: '1.0.0',
  });
});

module.exports = routeur;
