-- plsql/06_triggers_integrite.sql
-- Run as GLPI_OWNER on BOTH nodes

CREATE OR REPLACE TRIGGER trg_materiel_cohesion_site
BEFORE INSERT OR UPDATE OF materiel_id, utilisateur_id ON ATTRIBUTION
FOR EACH ROW
DECLARE
    v_site_materiel    MATERIEL.site_id%TYPE;
    v_site_utilisateur UTILISATEUR.site_id%TYPE;
BEGIN
    SELECT site_id
    INTO v_site_materiel
    FROM MATERIEL
    WHERE id = :NEW.materiel_id;

    SELECT site_id
    INTO v_site_utilisateur
    FROM UTILISATEUR
    WHERE id = :NEW.utilisateur_id;

    IF v_site_materiel <> v_site_utilisateur THEN
        PKG_EXCEPTIONS.raise_site_incompatible(
            'Attribution refusee : materiel et utilisateur sur des sites differents.'
        );
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        PKG_EXCEPTIONS.raise_attribution_invalide(
            'Attribution refusee : materiel ou utilisateur introuvable.'
        );
END;
/

CREATE OR REPLACE TRIGGER trg_port_vlan_meme_site
BEFORE INSERT OR UPDATE OF equipement_id, vlan_id ON PORT_RESEAU
FOR EACH ROW
DECLARE
    v_site_equipement EQUIPEMENT_RESEAU.site_id%TYPE;
    v_site_vlan       VLAN.site_id%TYPE;
BEGIN
    IF :NEW.vlan_id IS NULL THEN
        RETURN;
    END IF;

    SELECT site_id
    INTO v_site_equipement
    FROM EQUIPEMENT_RESEAU
    WHERE id = :NEW.equipement_id;

    SELECT site_id
    INTO v_site_vlan
    FROM VLAN
    WHERE id = :NEW.vlan_id;

    IF v_site_equipement <> v_site_vlan THEN
        PKG_EXCEPTIONS.raise_site_incompatible(
            'Port refuse : l''equipement reseau et le VLAN doivent appartenir au meme site.'
        );
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        PKG_EXCEPTIONS.raise_attribution_invalide(
            'Port refuse : equipement reseau ou VLAN introuvable.'
        );
END;
/

CREATE OR REPLACE TRIGGER trg_unique_mac
FOR INSERT OR UPDATE OF adresse_mac ON EQUIPEMENT_RESEAU
COMPOUND TRIGGER
    TYPE t_mac_list IS TABLE OF EQUIPEMENT_RESEAU.adresse_mac%TYPE INDEX BY PLS_INTEGER;
    g_mac_list t_mac_list;
    g_count    PLS_INTEGER := 0;

    BEFORE EACH ROW IS
    BEGIN
        IF :NEW.adresse_mac IS NOT NULL THEN
            g_count := g_count + 1;
            g_mac_list(g_count) := UPPER(:NEW.adresse_mac);
        END IF;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
        v_nb NUMBER;
    BEGIN
        FOR i IN 1 .. g_count LOOP
            SELECT COUNT(*)
            INTO v_nb
            FROM EQUIPEMENT_RESEAU
            WHERE UPPER(adresse_mac) = g_mac_list(i);

            IF v_nb > 1 THEN
                PKG_EXCEPTIONS.raise_mac_dupliquee(
                    'Adresse MAC deja affectee a un autre equipement reseau.'
                );
            END IF;
        END LOOP;
    END AFTER STATEMENT;
END trg_unique_mac;
/

CREATE OR REPLACE TRIGGER trg_unique_ip
FOR INSERT OR UPDATE OF adresse_ip ON EQUIPEMENT_RESEAU
COMPOUND TRIGGER
    TYPE t_ip_list IS TABLE OF EQUIPEMENT_RESEAU.adresse_ip%TYPE INDEX BY PLS_INTEGER;
    g_ip_list t_ip_list;
    g_count   PLS_INTEGER := 0;

    BEFORE EACH ROW IS
    BEGIN
        IF :NEW.adresse_ip IS NOT NULL AND :NEW.adresse_ip <> '0.0.0.0' THEN
            g_count := g_count + 1;
            g_ip_list(g_count) := :NEW.adresse_ip;
        END IF;
    END BEFORE EACH ROW;

    AFTER STATEMENT IS
        v_nb NUMBER;
    BEGIN
        FOR i IN 1 .. g_count LOOP
            SELECT COUNT(*)
            INTO v_nb
            FROM EQUIPEMENT_RESEAU
            WHERE adresse_ip = g_ip_list(i);

            IF v_nb > 1 THEN
                PKG_EXCEPTIONS.raise_ip_dupliquee(
                    'Adresse IP deja affectee a un autre equipement reseau.'
                );
            END IF;
        END LOOP;
    END AFTER STATEMENT;
END trg_unique_ip;
/

SHOW ERRORS TRIGGER trg_materiel_cohesion_site;
SHOW ERRORS TRIGGER trg_port_vlan_meme_site;
SHOW ERRORS TRIGGER trg_unique_mac;
SHOW ERRORS TRIGGER trg_unique_ip;

EXIT;
