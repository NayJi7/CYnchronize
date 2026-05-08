-- perf/04_global_views_pau.sql
-- Run as GLPI_OWNER on Pau (port 1522)

CREATE OR REPLACE VIEW V_MATERIELS_GLOBAL AS
    SELECT id, numero_serie, modele_id, site_id, location_id,
           date_achat, statut, etat, 'PAU' AS source
    FROM MATERIEL
    UNION ALL
    SELECT id, numero_serie, modele_id, site_id, location_id,
           date_achat, statut, etat, 'CERGY' AS source
    FROM MATERIEL@dblink_cergy;

CREATE OR REPLACE VIEW V_UTILISATEURS_GLOBAL AS
    SELECT id, login, nom, prenom, email, site_id, location_id,
           date_creation, actif, 'PAU' AS source
    FROM UTILISATEUR
    UNION ALL
    SELECT id, login, nom, prenom, email, site_id, location_id,
           date_creation, actif, 'CERGY' AS source
    FROM UTILISATEUR@dblink_cergy;

CREATE OR REPLACE VIEW V_EQUIPEMENTS_RESEAU_GLOBAL AS
    SELECT id, nom, type_id, site_id, location_id,
           adresse_mac, adresse_ip, 'PAU' AS source
    FROM EQUIPEMENT_RESEAU
    UNION ALL
    SELECT id, nom, type_id, site_id, location_id,
           adresse_mac, adresse_ip, 'CERGY' AS source
    FROM EQUIPEMENT_RESEAU@dblink_cergy;

GRANT SELECT ON V_MATERIELS_GLOBAL          TO ROLE_CONSULT;
GRANT SELECT ON V_UTILISATEURS_GLOBAL       TO ROLE_CONSULT;
GRANT SELECT ON V_EQUIPEMENTS_RESEAU_GLOBAL TO ROLE_CONSULT;

SELECT view_name FROM user_views
WHERE view_name LIKE 'V_%_GLOBAL'
ORDER BY view_name;

EXIT;
