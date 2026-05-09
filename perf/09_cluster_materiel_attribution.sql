-- perf/09_cluster_materiel_attribution.sql
-- Run as GLPI_OWNER on BOTH nodes
-- Cluster indexé sur materiel_id regroupant MATERIEL (maître) et ATTRIBUTION (détail)

-- Sauvegarde des données
CREATE TABLE temp_materiel    AS SELECT * FROM MATERIEL;
CREATE TABLE temp_attribution AS SELECT * FROM ATTRIBUTION;

-- Suppression des tables dans l'ordre (contrainte FK)
DROP TABLE ATTRIBUTION CASCADE CONSTRAINTS;
DROP TABLE MATERIEL    CASCADE CONSTRAINTS;

-- Création du cluster
CREATE CLUSTER CL_MATERIEL_ATTRIBUTION (materiel_id NUMBER)
    SIZE 512
    TABLESPACE TBS_MATERIELS;

-- Création des tables dans le cluster
CREATE TABLE MATERIEL (
    id            NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero_serie  VARCHAR2(100) NOT NULL,
    modele_id     NUMBER        NOT NULL,
    site_id       NUMBER        NOT NULL,
    location_id   NUMBER,
    date_achat    DATE,
    statut        VARCHAR2(30) DEFAULT 'en_service' NOT NULL,
    etat          VARCHAR2(30) DEFAULT 'fonctionnel' NOT NULL
) CLUSTER CL_MATERIEL_ATTRIBUTION (id);

CREATE TABLE ATTRIBUTION (
    id             NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    materiel_id    NUMBER NOT NULL,
    utilisateur_id NUMBER NOT NULL,
    date_debut     DATE DEFAULT SYSDATE NOT NULL,
    date_fin       DATE,
    motif          VARCHAR2(300)
) CLUSTER CL_MATERIEL_ATTRIBUTION (materiel_id);

-- Index du cluster (obligatoire avant insertion)
CREATE INDEX IDX_CL_MATERIEL_ATTRIBUTION ON CLUSTER CL_MATERIEL_ATTRIBUTION
    TABLESPACE TBS_INDEX;

-- Restauration des données
INSERT INTO MATERIEL (numero_serie, modele_id, site_id, location_id, date_achat, statut, etat)
    SELECT numero_serie, modele_id, site_id, location_id, date_achat, statut, etat
    FROM temp_materiel;

INSERT INTO ATTRIBUTION (materiel_id, utilisateur_id, date_debut, date_fin, motif)
    SELECT materiel_id, utilisateur_id, date_debut, date_fin, motif
    FROM temp_attribution;

COMMIT;

-- Suppression des tables temporaires
DROP TABLE temp_materiel;
DROP TABLE temp_attribution;

-- Recréation des contraintes FK et CHECK sur MATERIEL
ALTER TABLE MATERIEL ADD CONSTRAINT fk_materiel_modele
    FOREIGN KEY (modele_id) REFERENCES MODELE(id);
ALTER TABLE MATERIEL ADD CONSTRAINT fk_materiel_site
    FOREIGN KEY (site_id) REFERENCES SITE(id);
ALTER TABLE MATERIEL ADD CONSTRAINT fk_materiel_location
    FOREIGN KEY (location_id) REFERENCES LOCATION(id);
ALTER TABLE MATERIEL ADD CONSTRAINT chk_materiel_statut
    CHECK (statut IN ('en_service', 'en_stock', 'en_reparation', 'reforme', 'pret'));
ALTER TABLE MATERIEL ADD CONSTRAINT chk_materiel_etat
    CHECK (etat IN ('fonctionnel', 'defectueux', 'obsolete', 'neuf'));
ALTER TABLE MATERIEL ADD CONSTRAINT uk_materiel_serie
    UNIQUE (numero_serie);

-- Recréation des contraintes FK et CHECK sur ATTRIBUTION
ALTER TABLE ATTRIBUTION ADD CONSTRAINT fk_attribution_materiel
    FOREIGN KEY (materiel_id) REFERENCES MATERIEL(id);
ALTER TABLE ATTRIBUTION ADD CONSTRAINT fk_attribution_utilisateur
    FOREIGN KEY (utilisateur_id) REFERENCES UTILISATEUR(id);
ALTER TABLE ATTRIBUTION ADD CONSTRAINT chk_attribution_dates
    CHECK (date_fin IS NULL OR date_fin >= date_debut);

-- Recréation des index B-Tree sur ces tables
CREATE INDEX IDX_ATTRIBUTION_MATERIEL
    ON ATTRIBUTION (materiel_id)
    TABLESPACE TBS_INDEX;
CREATE INDEX IDX_ATTRIBUTION_UTILISATEUR
    ON ATTRIBUTION (utilisateur_id)
    TABLESPACE TBS_INDEX;
CREATE INDEX IDX_MATERIEL_MODELE
    ON MATERIEL (modele_id)
    TABLESPACE TBS_INDEX;
CREATE INDEX IDX_MATERIEL_SITE_STATUT
    ON MATERIEL (site_id, statut)
    TABLESPACE TBS_INDEX;
CREATE INDEX IDX_ATTRIBUTION_USER_DATEFIN
    ON ATTRIBUTION (utilisateur_id, date_fin)
    TABLESPACE TBS_INDEX;

SELECT table_name, cluster_name FROM user_tables
WHERE cluster_name = 'CL_MATERIEL_ATTRIBUTION';

EXIT;
