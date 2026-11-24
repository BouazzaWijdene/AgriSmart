const express = require('express');
const rateLimit = require('express-rate-limit');
const controleur = require('../controllers/auth.controller');
const { valider } = require('../middleware/validate');
const { authentifie } = require('../middleware/auth');
const reglesAuth = require('../validators/auth.validator');

const routeur = express.Router();

// Anti brute-force sur les endpoints sensibles : 20 tentatives / 15 min / IP.
const limiteAuth = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { erreur: 'Trop de tentatives, réessayez dans quelques minutes.' },
});

routeur.post('/inscription', limiteAuth, valider(reglesAuth.inscription), controleur.inscription);
routeur.post('/connexion', limiteAuth, valider(reglesAuth.connexion), controleur.connexion);
routeur.post('/mot-de-passe-oublie', limiteAuth, valider(reglesAuth.motDePasseOublie), controleur.motDePasseOublie);

routeur.get('/moi', authentifie, controleur.moi);
routeur.put('/profil', authentifie, valider(reglesAuth.profil), controleur.majProfil);
routeur.put('/mot-de-passe', authentifie, valider(reglesAuth.motDePasse), controleur.majMotDePasse);
routeur.post('/deconnexion', authentifie, controleur.deconnexion);

module.exports = routeur;
