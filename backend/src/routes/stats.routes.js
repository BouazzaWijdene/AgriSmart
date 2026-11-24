const express = require('express');
const controleur = require('../controllers/stats.controller');
const { authentifie } = require('../middleware/auth');

const routeur = express.Router();

routeur.use(authentifie);
routeur.get('/', controleur.tableauDeBord);

module.exports = routeur;
