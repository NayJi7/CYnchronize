-- plsql/05_pkg_admin_parc_body.sql
-- Run as GLPI_OWNER on BOTH nodes

CREATE OR REPLACE PACKAGE BODY PKG_ADMIN_PARC AS
    FUNCTION site_code(p_site_id IN SITE.id%TYPE) RETURN SITE.code%TYPE IS
        v_code SITE.code%TYPE;
    BEGIN
        SELECT code
        INTO v_code
        FROM SITE
        WHERE id = p_site_id;

        RETURN UPPER(v_code);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PKG_EXCEPTIONS.raise_site_incompatible('Site introuvable.');
            RAISE;
    END site_code;

    PROCEDURE verifier_site_attribution(
        p_materiel_id    IN MATERIEL.id%TYPE,
        p_utilisateur_id IN UTILISATEUR.id%TYPE
    ) IS
        v_site_materiel    MATERIEL.site_id%TYPE;
        v_site_utilisateur UTILISATEUR.site_id%TYPE;
    BEGIN
        SELECT site_id
        INTO v_site_materiel
        FROM MATERIEL
        WHERE id = p_materiel_id;

        SELECT site_id
        INTO v_site_utilisateur
        FROM UTILISATEUR
        WHERE id = p_utilisateur_id;

        IF v_site_materiel <> v_site_utilisateur THEN
            PKG_EXCEPTIONS.raise_site_incompatible(
                'Le materiel et l''utilisateur doivent appartenir au meme site.'
            );
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PKG_EXCEPTIONS.raise_attribution_invalide(
                'Materiel ou utilisateur introuvable pour l''attribution.'
            );
    END verifier_site_attribution;

    PROCEDURE attribuer_materiel(
        p_materiel_id    IN MATERIEL.id%TYPE,
        p_utilisateur_id IN UTILISATEUR.id%TYPE,
        p_motif          IN ATTRIBUTION.motif%TYPE DEFAULT NULL
    ) IS
        v_nb_attributions NUMBER;
    BEGIN
        verifier_site_attribution(p_materiel_id, p_utilisateur_id);

        SELECT COUNT(*)
        INTO v_nb_attributions
        FROM ATTRIBUTION
        WHERE materiel_id = p_materiel_id
          AND date_fin IS NULL;

        IF v_nb_attributions > 0 THEN
            PKG_EXCEPTIONS.raise_materiel_deja_attribue(
                'Le materiel possede deja une attribution active.'
            );
        END IF;

        INSERT INTO ATTRIBUTION (
            materiel_id,
            utilisateur_id,
            date_debut,
            date_fin,
            motif
        ) VALUES (
            p_materiel_id,
            p_utilisateur_id,
            SYSDATE,
            NULL,
            p_motif
        );

        UPDATE MATERIEL
        SET statut = 'pret'
        WHERE id = p_materiel_id;
    END attribuer_materiel;

    PROCEDURE cloturer_attribution(
        p_attribution_id IN ATTRIBUTION.id%TYPE,
        p_motif          IN ATTRIBUTION.motif%TYPE DEFAULT NULL
    ) IS
        v_date_fin ATTRIBUTION.date_fin%TYPE;
    BEGIN
        SELECT date_fin
        INTO v_date_fin
        FROM ATTRIBUTION
        WHERE id = p_attribution_id
        FOR UPDATE;

        IF v_date_fin IS NOT NULL THEN
            PKG_EXCEPTIONS.raise_attribution_invalide(
                'L''attribution est deja cloturee.'
            );
        END IF;

        UPDATE ATTRIBUTION
        SET date_fin = SYSDATE,
            motif = COALESCE(p_motif, motif)
        WHERE id = p_attribution_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PKG_EXCEPTIONS.raise_attribution_invalide(
                'Attribution introuvable.'
            );
    END cloturer_attribution;

    PROCEDURE transferer_materiel_inter_sites(
        p_materiel_id      IN MATERIEL.id%TYPE,
        p_site_dest_id     IN SITE.id%TYPE,
        p_location_dest_id IN LOCATION.id%TYPE DEFAULT NULL
    ) IS
        v_materiel       MATERIEL%ROWTYPE;
        v_site_dest_code SITE.code%TYPE;
        v_nb_location    NUMBER;
    BEGIN
        SELECT *
        INTO v_materiel
        FROM MATERIEL
        WHERE id = p_materiel_id
        FOR UPDATE;

        IF v_materiel.site_id = p_site_dest_id THEN
            PKG_EXCEPTIONS.raise_site_incompatible(
                'Le site de destination est identique au site actuel.'
            );
        END IF;

        IF p_location_dest_id IS NOT NULL THEN
            SELECT COUNT(*)
            INTO v_nb_location
            FROM LOCATION
            WHERE id = p_location_dest_id
              AND site_id = p_site_dest_id;

            IF v_nb_location = 0 THEN
                PKG_EXCEPTIONS.raise_site_incompatible(
                    'La location de destination ne correspond pas au site de destination.'
                );
            END IF;
        END IF;

        FOR r_attribution IN (
            SELECT id
            FROM ATTRIBUTION
            WHERE materiel_id = p_materiel_id
              AND date_fin IS NULL
        ) LOOP
            cloturer_attribution(r_attribution.id, 'Transfert inter-sites');
        END LOOP;

        v_site_dest_code := site_code(p_site_dest_id);

        IF v_site_dest_code = 'CERGY' THEN
            EXECUTE IMMEDIATE
                'INSERT INTO GLPI_OWNER.MATERIEL@dblink_cergy (
                    numero_serie, modele_id, site_id, location_id,
                    date_achat, statut, etat
                 ) VALUES (:1, :2, :3, :4, :5, :6, :7)'
            USING v_materiel.numero_serie,
                  v_materiel.modele_id,
                  p_site_dest_id,
                  p_location_dest_id,
                  v_materiel.date_achat,
                  'en_stock',
                  v_materiel.etat;
        ELSIF v_site_dest_code = 'PAU' THEN
            EXECUTE IMMEDIATE
                'INSERT INTO GLPI_OWNER.MATERIEL@dblink_pau (
                    numero_serie, modele_id, site_id, location_id,
                    date_achat, statut, etat
                 ) VALUES (:1, :2, :3, :4, :5, :6, :7)'
            USING v_materiel.numero_serie,
                  v_materiel.modele_id,
                  p_site_dest_id,
                  p_location_dest_id,
                  v_materiel.date_achat,
                  'en_stock',
                  v_materiel.etat;
        ELSE
            PKG_EXCEPTIONS.raise_site_incompatible(
                'Site de destination non gere pour un transfert inter-sites.'
            );
        END IF;

        DELETE FROM ATTRIBUTION
        WHERE materiel_id = p_materiel_id;

        DELETE FROM MATERIEL
        WHERE id = p_materiel_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PKG_EXCEPTIONS.raise_attribution_invalide(
                'Materiel introuvable pour le transfert inter-sites.'
            );
    END transferer_materiel_inter_sites;

    PROCEDURE generer_inventaire_site(
        p_site_id IN SITE.id%TYPE,
        p_cursor  OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT m.id AS materiel_id,
                   m.numero_serie,
                   tm.libelle AS type_materiel,
                   c.nom AS constructeur,
                   mo.reference AS modele,
                   m.statut,
                   m.etat,
                   m.date_achat,
                   PKG_FONCTIONS_METIER.age_materiel_mois(m.id) AS age_mois,
                   PKG_FONCTIONS_METIER.est_obsolete(m.id) AS est_obsolete,
                   l.batiment,
                   l.etage,
                   l.salle
            FROM MATERIEL m
            JOIN MODELE mo ON mo.id = m.modele_id
            JOIN CONSTRUCTEUR c ON c.id = mo.constructeur_id
            JOIN TYPE_MATERIEL tm ON tm.id = mo.type_materiel_id
            LEFT JOIN LOCATION l ON l.id = m.location_id
            WHERE m.site_id = p_site_id
            ORDER BY tm.libelle, c.nom, mo.reference, m.numero_serie;
    END generer_inventaire_site;
END PKG_ADMIN_PARC;
/

SHOW ERRORS PACKAGE BODY PKG_ADMIN_PARC;

EXIT;
