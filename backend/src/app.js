const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const config = require('./config/env');
const routes = require('./routes');
const { nonTrouve } = require('./middleware/notFound');
const { gestionnaireErreurs } = require('./middleware/errorHandler');

/**
 * Fabrique l'application Express.
 * Séparée du serveur (server.js) pour rester testable sans ouvrir de port.
 */
function creerApplication() {
  const application = express();

  // Derrière un reverse proxy (nginx, Render, Railway…) : IP client réelle pour le rate-limit.
  application.set('trust proxy', 1);

  // ---------- Middlewares de sécurité & observabilité ----------
  application.use(helmet());

  const optionsCors = config.corsOrigines === '*'
    ? { origin: true }
    : { origin: config.corsOrigines.split(',').map((o) => o.trim()) };
  application.use(cors(optionsCors));

  application.use(express.json({ limit: '100kb' }));
  application.use(morgan(config.nodeEnv === 'production' ? 'combined' : 'dev'));

  // ---------- Routes ----------
  application.get('/', (_requete, reponse) => {
    reponse.json({
      api: 'Agrismart API',
      version: '1.0.0',
      sante: '/api/sante',
      documentation: 'Voir backend/README.md',
    });
  });

  application.use('/api', routes);

  // ---------- Erreurs (404 puis gestionnaire central) ----------
  application.use(nonTrouve);
  application.use(gestionnaireErreurs);

  return application;
}

module.exports = { creerApplication };
