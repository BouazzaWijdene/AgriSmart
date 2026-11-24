const zoneModel = require('../models/zone.model');

/**
 * GET /api/stats — tableau de bord de l'utilisateur authentifié :
 * nombre de zones, humidité moyenne, zones à irriguer, vannes ouvertes…
 */
async function tableauDeBord(requete, reponse) {
  const stats = await zoneModel.statistiques(requete.utilisateur.id);
  reponse.json(stats);
}

module.exports = { tableauDeBord };
