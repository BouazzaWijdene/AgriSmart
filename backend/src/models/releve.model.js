const { requete, transaction } = require('../config/database');
const { versZoneApi } = require('./zone.model');

/**
 * Enregistre un relevé d'humidité et met à jour la zone dans une transaction
 * atomique. Règle métier « irrigation intelligente » : si le relevé atteint
 * le seuil, la vanne est refermée automatiquement.
 * @returns {object|null} la zone mise à jour, ou null si non trouvée.
 */
async function enregistrer(zoneId, utilisateurId, humidite) {
  return transaction(async (client) => {
    const zone = await client.query(
      'SELECT id FROM zones WHERE id = $1 AND utilisateur_id = $2 FOR UPDATE',
      [zoneId, utilisateurId],
    );
    if (zone.rows.length === 0) return null;

    await client.query(
      'INSERT INTO releves_humidite (zone_id, humidite) VALUES ($1, $2)',
      [zoneId, humidite],
    );

    const maj = await client.query(
      `UPDATE zones
         SET humidite = $2,
             vanne_ouverte = CASE WHEN $2 >= seuil THEN FALSE ELSE vanne_ouverte END
       WHERE id = $1
       RETURNING *`,
      [zoneId, humidite],
    );
    return versZoneApi(maj.rows[0]);
  });
}

/** Historique des relevés d'une zone sur les N derniers jours. */
async function listerParZone(zoneId, jours, limite = 500) {
  const resultat = await requete(
    `SELECT id, humidite, enregistre_le
       FROM releves_humidite
      WHERE zone_id = $1 AND enregistre_le >= now() - ($2::int * interval '1 day')
      ORDER BY enregistre_le DESC
      LIMIT $3`,
    [zoneId, jours, limite],
  );
  return resultat.rows.map((r) => ({
    id: r.id,
    humidite: Number(r.humidite),
    enregistreLe: r.enregistre_le,
  }));
}

module.exports = { enregistrer, listerParZone };
