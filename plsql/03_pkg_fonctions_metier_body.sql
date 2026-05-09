-- plsql/03_pkg_fonctions_metier_body.sql
-- Run as GLPI_OWNER on BOTH nodes

CREATE OR REPLACE PACKAGE BODY PKG_FONCTIONS_METIER AS
    FUNCTION age_materiel_mois(
        p_materiel_id IN MATERIEL.id%TYPE
    ) RETURN NUMBER IS
        v_date_achat MATERIEL.date_achat%TYPE;
    BEGIN
        SELECT date_achat
        INTO v_date_achat
        FROM MATERIEL
        WHERE id = p_materiel_id;

        IF v_date_achat IS NULL THEN
            RETURN NULL;
        END IF;

        RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, v_date_achat));
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PKG_EXCEPTIONS.raise_attribution_invalide(
                'Materiel introuvable pour le calcul de son age.'
            );
            RAISE;
    END age_materiel_mois;

    FUNCTION est_obsolete(
        p_materiel_id IN MATERIEL.id%TYPE
    ) RETURN NUMBER IS
        v_age_mois NUMBER;
    BEGIN
        v_age_mois := age_materiel_mois(p_materiel_id);

        IF v_age_mois IS NOT NULL AND v_age_mois >= 60 THEN
            RETURN 1;
        END IF;

        RETURN 0;
    END est_obsolete;

    FUNCTION nb_materiels_attribues(
        p_utilisateur_id IN UTILISATEUR.id%TYPE
    ) RETURN NUMBER IS
        v_nb NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_nb
        FROM ATTRIBUTION
        WHERE utilisateur_id = p_utilisateur_id
          AND date_fin IS NULL;

        RETURN v_nb;
    END nb_materiels_attribues;

    FUNCTION taux_occupation_ports(
        p_equipement_id IN EQUIPEMENT_RESEAU.id%TYPE
    ) RETURN NUMBER IS
        v_total_ports   NUMBER;
        v_ports_utilises NUMBER;
    BEGIN
        SELECT COUNT(*),
               SUM(CASE WHEN statut = 'utilise' OR materiel_connecte_id IS NOT NULL THEN 1 ELSE 0 END)
        INTO v_total_ports,
             v_ports_utilises
        FROM PORT_RESEAU
        WHERE equipement_id = p_equipement_id;

        IF v_total_ports = 0 THEN
            RETURN 0;
        END IF;

        RETURN ROUND((NVL(v_ports_utilises, 0) / v_total_ports) * 100, 2);
    END taux_occupation_ports;
END PKG_FONCTIONS_METIER;
/

SHOW ERRORS PACKAGE BODY PKG_FONCTIONS_METIER;

EXIT;
