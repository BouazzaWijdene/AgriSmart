const jwt = require('jsonwebtoken');
const config = require('../config/env');

/**
 * Génère le JWT d'authentification d'un utilisateur.
 * La charge utile embarque l'identité minimale (subject = UUID, email, rôle).
 * @param {{id: string, email: string, role: string}} utilisateur
 * @returns {string} jeton signé (HS256)
 */
function genererJeton(utilisateur) {
  return jwt.sign(
    { email: utilisateur.email, role: utilisateur.role },
    config.jwt.secret,
    { subject: utilisateur.id, expiresIn: config.jwt.duree },
  );
}

/**
 * Vérifie un JWT et renvoie sa charge utile.
 * @throws {TokenExpiredError|JsonWebTokenError} si le jeton est invalide ou expiré.
 */
function verifierJeton(jeton) {
  return jwt.verify(jeton, config.jwt.secret);
}

module.exports = { genererJeton, verifierJeton };
