const { Pool } = require('pg');
const config = require('./env');

/**
 * Pool de connexions PostgreSQL partagé par toute l'application.
 * Un seul pool par processus : les requêtes parallèles le réutilisent.
 */
const pool = new Pool({
  host: config.pg.host,
  port: config.pg.port,
  user: config.pg.utilisateur,
  password: config.pg.motDePasse,
  database: config.pg.base,
  max: 10,                      // 10 connexions maximum
  idleTimeoutMillis: 30_000,    // fermeture des connexions inactives après 30 s
  connectionTimeoutMillis: 5_000, // échec rapide si la base est injoignable
});

pool.on('error', (erreur) => {
  console.error('[DB] Erreur inattendue du pool PostgreSQL :', erreur.message);
});

/** Exécute une requête SQL paramétrée. */
async function requete(texte, parametres = []) {
  return pool.query(texte, parametres);
}

/** Exécute une requête et renvoie la première ligne (ou null). */
async function uneLigne(texte, parametres = []) {
  const resultat = await requete(texte, parametres);
  return resultat.rows[0] ?? null;
}

/** Vérifie que la base répond (sonde de santé). */
async function testerConnexion() {
  await requete('SELECT 1');
}

/**
 * Exécute le callback dans une transaction atomique.
 * COMMIT si tout réussit, ROLLBACK en cas d'erreur.
 * @param {(client: import('pg').PoolClient) => Promise<*>} callback
 */
async function transaction(callback) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const resultat = await callback(client);
    await client.query('COMMIT');
    return resultat;
  } catch (erreur) {
    await client.query('ROLLBACK');
    throw erreur;
  } finally {
    client.release();
  }
}

/** Ferme proprement le pool (arrêt gracieux du serveur). */
async function fermerPool() {
  await pool.end();
}

module.exports = { pool, requete, uneLigne, testerConnexion, transaction, fermerPool };
