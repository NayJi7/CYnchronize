-- schema/03_constraints.sql
-- Run as GLPI_OWNER on BOTH nodes

-- ============================================================
-- Referential integrity (Foreign Keys)
-- ============================================================
ALTER TABLE LOCATION ADD CONSTRAINT fk_location_site
    FOREIGN KEY (site_id) REFERENCES SITE(id);

ALTER TABLE UTILISATEUR ADD CONSTRAINT fk_utilisateur_site
    FOREIGN KEY (site_id) REFERENCES SITE(id);

ALTER TABLE UTILISATEUR ADD CONSTRAINT fk_utilisateur_location
    FOREIGN KEY (location_id) REFERENCES LOCATION(id);

ALTER TABLE UTILISATEUR_GROUPE ADD CONSTRAINT fk_ug_utilisateur
    FOREIGN KEY (utilisateur_id) REFERENCES UTILISATEUR(id);

ALTER TABLE UTILISATEUR_GROUPE ADD CONSTRAINT fk_ug_groupe
    FOREIGN KEY (groupe_id) REFERENCES GROUPE(id);

ALTER TABLE UTILISATEUR_PROFIL ADD CONSTRAINT fk_up_utilisateur
    FOREIGN KEY (utilisateur_id) REFERENCES UTILISATEUR(id);

ALTER TABLE UTILISATEUR_PROFIL ADD CONSTRAINT fk_up_profil
    FOREIGN KEY (profil_id) REFERENCES PROFIL(id);

ALTER TABLE MODELE ADD CONSTRAINT fk_modele_constructeur
    FOREIGN KEY (constructeur_id) REFERENCES CONSTRUCTEUR(id);

ALTER TABLE MODELE ADD CONSTRAINT fk_modele_type
    FOREIGN KEY (type_materiel_id) REFERENCES TYPE_MATERIEL(id);

ALTER TABLE MATERIEL ADD CONSTRAINT fk_materiel_modele
    FOREIGN KEY (modele_id) REFERENCES MODELE(id);

ALTER TABLE MATERIEL ADD CONSTRAINT fk_materiel_site
    FOREIGN KEY (site_id) REFERENCES SITE(id);

ALTER TABLE MATERIEL ADD CONSTRAINT fk_materiel_location
    FOREIGN KEY (location_id) REFERENCES LOCATION(id);

ALTER TABLE ATTRIBUTION ADD CONSTRAINT fk_attribution_materiel
    FOREIGN KEY (materiel_id) REFERENCES MATERIEL(id);

ALTER TABLE ATTRIBUTION ADD CONSTRAINT fk_attribution_utilisateur
    FOREIGN KEY (utilisateur_id) REFERENCES UTILISATEUR(id);

ALTER TABLE EQUIPEMENT_RESEAU ADD CONSTRAINT fk_eq_type
    FOREIGN KEY (type_id) REFERENCES TYPE_EQUIPEMENT_RESEAU(id);

ALTER TABLE EQUIPEMENT_RESEAU ADD CONSTRAINT fk_eq_site
    FOREIGN KEY (site_id) REFERENCES SITE(id);

ALTER TABLE EQUIPEMENT_RESEAU ADD CONSTRAINT fk_eq_location
    FOREIGN KEY (location_id) REFERENCES LOCATION(id);

ALTER TABLE VLAN ADD CONSTRAINT fk_vlan_site
    FOREIGN KEY (site_id) REFERENCES SITE(id);

ALTER TABLE PORT_RESEAU ADD CONSTRAINT fk_port_equipement
    FOREIGN KEY (equipement_id) REFERENCES EQUIPEMENT_RESEAU(id);

ALTER TABLE PORT_RESEAU ADD CONSTRAINT fk_port_vlan
    FOREIGN KEY (vlan_id) REFERENCES VLAN(id);

ALTER TABLE PORT_RESEAU ADD CONSTRAINT fk_port_materiel
    FOREIGN KEY (materiel_connecte_id) REFERENCES MATERIEL(id);

-- ============================================================
-- Check constraints
-- ============================================================
ALTER TABLE MATERIEL ADD CONSTRAINT chk_materiel_statut
    CHECK (statut IN ('en_service', 'en_stock', 'en_reparation', 'reforme', 'pret'));

ALTER TABLE MATERIEL ADD CONSTRAINT chk_materiel_etat
    CHECK (etat IN ('fonctionnel', 'defectueux', 'obsolete', 'neuf'));

ALTER TABLE PORT_RESEAU ADD CONSTRAINT chk_port_statut
    CHECK (statut IN ('libre', 'utilise', 'desactive'));

ALTER TABLE UTILISATEUR ADD CONSTRAINT chk_utilisateur_actif
    CHECK (actif IN (0, 1));

ALTER TABLE ATTRIBUTION ADD CONSTRAINT chk_attribution_dates
    CHECK (date_fin IS NULL OR date_fin >= date_debut);

-- ============================================================
-- Unique constraints
-- ============================================================
ALTER TABLE SITE ADD CONSTRAINT uk_site_code UNIQUE (code);
ALTER TABLE UTILISATEUR ADD CONSTRAINT uk_utilisateur_login UNIQUE (login);
ALTER TABLE MATERIEL ADD CONSTRAINT uk_materiel_serie UNIQUE (numero_serie);

-- Verify
SELECT table_name, constraint_name, constraint_type
FROM user_constraints
WHERE constraint_type IN ('R','C','U')
ORDER BY table_name, constraint_type;

EXIT;
