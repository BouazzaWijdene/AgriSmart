-- ============================================================
--  Schéma de la base « agrismart » — Agrismart API
--  Compatible PostgreSQL 14+. Script idempotent (relançable).
-- ============================================================

-- ---------- Utilisateurs ----------
CREATE TABLE IF NOT EXISTS utilisateurs (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email         VARCHAR(255) NOT NULL UNIQUE,
    mot_de_passe  VARCHAR(255) NOT NULL,
    nom           VARCHAR(100),
    prenom        VARCHAR(100),
    role          VARCHAR(20)  NOT NULL DEFAULT 'agriculteur'
                  CHECK (role IN ('agriculteur', 'admin')),
    cree_le       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    modifie_le    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ---------- Zones de culture ----------
CREATE TABLE IF NOT EXISTS zones (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    utilisateur_id UUID          NOT NULL REFERENCES utilisateurs (id) ON DELETE CASCADE,
    nom            VARCHAR(100)  NOT NULL,
    culture        VARCHAR(100)  NOT NULL,
    superficie_ha  NUMERIC(10,2) CHECK (superficie_ha > 0),
    humidite       NUMERIC(5,2)  NOT NULL CHECK (humidite >= 0 AND humidite <= 100),
    seuil          NUMERIC(5,2)  NOT NULL CHECK (seuil >= 0 AND seuil <= 100),
    vanne_ouverte  BOOLEAN       NOT NULL DEFAULT FALSE,
    cree_le        TIMESTAMPTZ   NOT NULL DEFAULT now(),
    modifie_le     TIMESTAMPTZ   NOT NULL DEFAULT now(),
    UNIQUE (utilisateur_id, nom)  -- un utilisateur ne peut pas avoir deux zones homonymes
);

-- ---------- Relevés d'humidité (historique) ----------
CREATE TABLE IF NOT EXISTS releves_humidite (
    id            BIGSERIAL PRIMARY KEY,
    zone_id       UUID         NOT NULL REFERENCES zones (id) ON DELETE CASCADE,
    humidite      NUMERIC(5,2) NOT NULL CHECK (humidite >= 0 AND humidite <= 100),
    enregistre_le TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ---------- Index de performance ----------
CREATE INDEX IF NOT EXISTS idx_zones_utilisateur ON zones (utilisateur_id);
CREATE INDEX IF NOT EXISTS idx_releves_zone_date ON releves_humidite (zone_id, enregistre_le DESC);

-- ---------- Horodatage automatique de « modifie_le » ----------
CREATE OR REPLACE FUNCTION set_modifie_le() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    NEW.modifie_le = now();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_utilisateurs_modifie
    BEFORE UPDATE ON utilisateurs
    FOR EACH ROW EXECUTE FUNCTION set_modifie_le();

CREATE OR REPLACE TRIGGER trg_zones_modifie
    BEFORE UPDATE ON zones
    FOR EACH ROW EXECUTE FUNCTION set_modifie_le();
