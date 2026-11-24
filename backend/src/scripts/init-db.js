/**
 * Applique le schéma SQL à la base (tables, index, triggers).
 * Usage : npm run db:init
 * Prérequis : la base et le rôle doivent exister (voir scripts/setup-db.ps1)
 * et être configurés dans backend/.env.
 */
const fs = require('node:fs');
const path = require('node:path');
const { requete, fermerPool } = require('../config/database');

async function initialiser() {
  const cheminSchema = path.join(__dirname, '..', 'sql', 'schema.sql');
  const schema = fs.readFileSync(cheminSchema, 'utf8');

  console.log('[db:init] Application du schéma PostgreSQL…');
  await requete(schema);
  console.log('[db:init] Schéma appliqué avec succès ✔');
}

initialiser()
  .then(() => fermerPool())
  .then(() => process.exit(0))
  .catch((erreur) => {
    console.error(`[db:init] Échec : ${erreur.message}`);
    process.exit(1);
  });
