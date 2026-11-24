const express = require('express');
const controleur = require('../controllers/meteo.controller');
const { authentifie } = require('../middleware/auth');

const routeur = express.Router();

routeur.use(authentifie);
routeur.get('/', controleur.actuelle);

module.exports = routeur;
