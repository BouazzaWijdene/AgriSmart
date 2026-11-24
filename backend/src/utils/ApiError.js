/**
 * Erreur applicative transportant un code HTTP, un message et des détails.
 * Permet aux contrôleurs de signaler proprement une erreur métier,
 * interceptée ensuite par le gestionnaire d'erreurs central.
 */
class ApiError extends Error {
  /**
   * @param {number} statut  Code HTTP de la réponse (ex. 404, 422, 409).
   * @param {string} message Message d'erreur compréhensible par le client.
   * @param {string[]|undefined} details Détails additionnels (ex. erreurs de validation).
   */
  constructor(statut, message, details = undefined) {
    super(message);
    this.name = 'ApiError';
    this.statut = statut;
    this.details = details;
    Error.captureStackTrace?.(this, ApiError);
  }
}

module.exports = { ApiError };
