/**
 * Jeu de données de démonstration : compte utilisateur + zones (issues du
 * jeu de données de l'application Flutter) + historique de relevés.
 * Usage : npm run db:seed   (idempotent : réinitialise le compte démo)
 *
 * Compte de démonstration : demo@agrismart.com / Demo1234!
 */
const bcrypt = require('bcryptjs');
const { requete, uneLigne, fermerPool } = require('../config/database');

const COMPTE_DEMO = {
  email: 'demo@agrismart.com',
  motDePasse: 'Demo1234!',
};

// Reprend les données de lib/data/jeu_de_donnees.dart
const ZONES_DEMO = [
  { nom: 'Parcelle Nord',  culture: 'Tomates',  humidite: 58, seuil: 40, superficie: 2.5 },
  { nom: 'Parcelle Sud',   culture: 'Carottes', humidite: 45, seuil: 50, superficie: 1.8 },
  { nom: 'Parcelle Est',   culture: 'Persil',   humidite: 70, seuil: 40, superficie: 0.5 },
  { nom: 'Parcelle Ouest', culture: 'Poivrons', humidite: 35, seuil: 45, superficie: 1.2 },
];

async function peupler() {
  console.log('[db:seed] Réinitialisation des données de démonstration…');
  await requete('DELETE FROM utilisateurs WHERE email = $1', [COMPTE_DEMO.email]);

  // 1. Compte de démonstration (mot de passe haché avec bcrypt, jamais en clair)
  const motDePasseHash = await bcrypt.hash(COMPTE_DEMO.motDePasse, 10);
  const utilisateur = await uneLigne(
    `INSERT INTO utilisateurs (email, mot_de_passe, nom, prenom, role)
     VALUES ($1, $2, $3, $4, 'admin')
     RETURNING id`,
    [COMPTE_DEMO.email, motDePasseHash, 'Ben Salah', 'Karim'],
  );

  // 2. Zones + historique synthétique (3 relevés/jour sur 7 jours)
  for (const zone of ZONES_DEMO) {
    const cree = await uneLigne(
      `INSERT INTO zones (utilisateur_id, nom, culture, superficie_ha, humidite, seuil)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id`,
      [utilisateur.id, zone.nom, zone.culture, zone.superficie, zone.humidite, zone.seuil],
    );

    for (let jours = 7; jours >= 1; jours--) {
      for (const heure of [6, 12, 18]) {
        const humidite = Math.max(
          5,
          Math.min(95, zone.humidite + (Math.random() * 20 - 10)),
        );
        await requete(
          `INSERT INTO releves_humidite (zone_id, humidite, enregistre_le)
           VALUES ($1, $2, now() - ($3::int * interval '1 day') - ($4::int * interval '1 hour'))`,
          [cree.id, humidite.toFixed(1), jours, (24 - heure) % 24],
        );
      }
    }

    console.log(`[db:seed]   Zone créée : ${zone.nom} (${zone.culture})`);
  }

  console.log('[db:seed] Terminé ✔');
  console.log(`[db:seed] Compte de démonstration : ${COMPTE_DEMO.email} / ${COMPTE_DEMO.motDePasse}`);
}

peupler()
  .then(() => fermerPool())
  .then(() => process.exit(0))
  .catch((erreur) => {
    console.error(`[db:seed] Échec : ${erreur.message}`);
    process.exit(1);
  });
