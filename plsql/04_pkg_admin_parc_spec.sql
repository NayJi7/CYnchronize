-- plsql/04_pkg_admin_parc_spec.sql
-- Run as GLPI_OWNER on BOTH nodes

CREATE OR REPLACE PACKAGE PKG_ADMIN_PARC AS
    PROCEDURE attribuer_materiel(
        p_materiel_id    IN MATERIEL.id%TYPE,
        p_utilisateur_id IN UTILISATEUR.id%TYPE,
        p_motif          IN ATTRIBUTION.motif%TYPE DEFAULT NULL
    );

    PROCEDURE transferer_materiel_inter_sites(
        p_materiel_id   IN MATERIEL.id%TYPE,
        p_site_dest_id  IN SITE.id%TYPE,
        p_location_dest_id IN LOCATION.id%TYPE DEFAULT NULL
    );

    PROCEDURE cloturer_attribution(
        p_attribution_id IN ATTRIBUTION.id%TYPE,
        p_motif          IN ATTRIBUTION.motif%TYPE DEFAULT NULL
    );

    PROCEDURE generer_inventaire_site(
        p_site_id IN SITE.id%TYPE,
        p_cursor  OUT SYS_REFCURSOR
    );
END PKG_ADMIN_PARC;
/

SHOW ERRORS PACKAGE PKG_ADMIN_PARC;

EXIT;
