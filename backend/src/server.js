const { creerApplication } = require('./app');
const config = require('./config/env');
const { testerConnexion, fermerPool } = require('./config/database');

const application = creerApplication();

async function demarrer() {
  // Vérification de la base au démarrage : l'API démarre même si la base
  // est momentanément indisponible — les routes SQL renverront alors 503.
  try {
    await testerConnexion();
    console.log('[DB] Connexion PostgreSQL établie ✔');
  } catch (erreur) {
    console.warn(`[DB] Base indisponible au démarrage : ${erreur.message}`);
    console.warn('[DB] Vérifiez la configuration (.env) puis exécutez « npm run db:init ».');
  }

  const serveur = application.listen(config.port, () => {
    console.log(`[API] Agrismart API démarrée sur http://localhost:${config.port} (${config.nodeEnv})`);
  });

  // ---------- Arrêt gracieux (Ctrl+C, déploiement, docker stop…) ----------
  const arreter = (signal) => {
    console.log(`\n[API] Signal ${signal} reçu, arrêt en cours…`);
    serveur.close(async () => {
      await fermerPool();
      console.log('[API] Arrêt propre terminé.');
      process.exit(0);
    });
  };

  process.on('SIGINT', () => arreter('SIGINT'));
  process.on('SIGTERM', () => arreter('SIGTERM'));
}

demarrer();
