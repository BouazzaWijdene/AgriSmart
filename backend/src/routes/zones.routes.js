const express = require('express');
const controleur = require('../controllers/zones.controller');
const { authentifie } = require('../middleware/auth');
const { valider } = require('../middleware/validate');
const reglesZone = require('../validators/zone.validator');

const routeur = express.Router();

// Toutes les routes « zones » exigent un jeton valide.
routeur.use(authentifie);

routeur.get('/', controleur.lister);
routeur.post('/', valider(reglesZone.creation), controleur.creer);
routeur.get('/:id', controleur.detail);
routeur.put('/:id', valider(reglesZone.miseAJour), controleur.mettreAJour);
routeur.delete('/:id', controleur.supprimer);
routeur.patch('/:id/vanne', valider(reglesZone.vanne), controleur.basculerVanne);
routeur.post('/:id/humidite', valider(reglesZone.humidite), controleur.enregistrerHumidite);
routeur.get('/:id/historique', valider(reglesZone.historique), controleur.historique);

module.exports = routeur;
