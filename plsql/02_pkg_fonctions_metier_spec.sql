-- plsql/02_pkg_fonctions_metier_spec.sql
-- Run as GLPI_OWNER on BOTH nodes

CREATE OR REPLACE PACKAGE PKG_FONCTIONS_METIER AS
    FUNCTION age_materiel_mois(
        p_materiel_id IN MATERIEL.id%TYPE
    ) RETURN NUMBER;

    FUNCTION est_obsolete(
        p_materiel_id IN MATERIEL.id%TYPE
    ) RETURN NUMBER;

    FUNCTION nb_materiels_attribues(
        p_utilisateur_id IN UTILISATEUR.id%TYPE
    ) RETURN NUMBER;

    FUNCTION taux_occupation_ports(
        p_equipement_id IN EQUIPEMENT_RESEAU.id%TYPE
    ) RETURN NUMBER;
END PKG_FONCTIONS_METIER;
/

SHOW ERRORS PACKAGE PKG_FONCTIONS_METIER;

EXIT;
