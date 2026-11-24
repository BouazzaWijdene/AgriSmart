/**
 * Middleware 404 : toute requête non interceptée par une route
 * reçoit une réponse JSON cohérente avec le reste de l'API.
 */
function nonTrouve(requete, reponse) {
  reponse.status(404).json({
    erreur: `Route introuvable : ${requete.method} ${requete.originalUrl}`,
  });
}

module.exports = { nonTrouve };
