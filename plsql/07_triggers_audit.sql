-- plsql/07_triggers_audit.sql
-- Run as GLPI_OWNER on BOTH nodes

CREATE OR REPLACE PROCEDURE ecrire_audit(
    p_table     IN JOURNAL_AUDIT.table_concernee%TYPE,
    p_operation IN JOURNAL_AUDIT.operation%TYPE,
    p_id        IN JOURNAL_AUDIT.id_enregistrement%TYPE,
    p_ancien    IN JOURNAL_AUDIT.ancien_valeur%TYPE,
    p_nouveau   IN JOURNAL_AUDIT.nouvelle_valeur%TYPE
) AS
BEGIN
    INSERT INTO JOURNAL_AUDIT (
        table_concernee,
        operation,
        id_enregistrement,
        ancien_valeur,
        nouvelle_valeur,
        utilisateur_oracle,
        date_action
    ) VALUES (
        p_table,
        p_operation,
        p_id,
        p_ancien,
        p_nouveau,
        USER,
        SYSDATE
    );
END;
/

CREATE OR REPLACE FUNCTION serializer_materiel(
    p_id           IN MATERIEL.id%TYPE,
    p_numero_serie IN MATERIEL.numero_serie%TYPE,
    p_modele_id    IN MATERIEL.modele_id%TYPE,
    p_site_id      IN MATERIEL.site_id%TYPE,
    p_location_id  IN MATERIEL.location_id%TYPE,
    p_date_achat   IN MATERIEL.date_achat%TYPE,
    p_statut       IN MATERIEL.statut%TYPE,
    p_etat         IN MATERIEL.etat%TYPE
) RETURN CLOB AS
BEGIN
    RETURN 'id=' || p_id
        || ';numero_serie=' || p_numero_serie
        || ';modele_id=' || p_modele_id
        || ';site_id=' || p_site_id
        || ';location_id=' || p_location_id
        || ';date_achat=' || TO_CHAR(p_date_achat, 'YYYY-MM-DD HH24:MI:SS')
        || ';statut=' || p_statut
        || ';etat=' || p_etat;
END;
/

CREATE OR REPLACE FUNCTION serializer_utilisateur(
    p_id            IN UTILISATEUR.id%TYPE,
    p_login         IN UTILISATEUR.login%TYPE,
    p_nom           IN UTILISATEUR.nom%TYPE,
    p_prenom        IN UTILISATEUR.prenom%TYPE,
    p_email         IN UTILISATEUR.email%TYPE,
    p_site_id       IN UTILISATEUR.site_id%TYPE,
    p_location_id   IN UTILISATEUR.location_id%TYPE,
    p_date_creation IN UTILISATEUR.date_creation%TYPE,
    p_actif         IN UTILISATEUR.actif%TYPE
) RETURN CLOB AS
BEGIN
    RETURN 'id=' || p_id
        || ';login=' || p_login
        || ';nom=' || p_nom
        || ';prenom=' || p_prenom
        || ';email=' || p_email
        || ';site_id=' || p_site_id
        || ';location_id=' || p_location_id
        || ';date_creation=' || TO_CHAR(p_date_creation, 'YYYY-MM-DD HH24:MI:SS')
        || ';actif=' || p_actif;
END;
/

CREATE OR REPLACE FUNCTION serializer_attribution(
    p_id             IN ATTRIBUTION.id%TYPE,
    p_materiel_id    IN ATTRIBUTION.materiel_id%TYPE,
    p_utilisateur_id IN ATTRIBUTION.utilisateur_id%TYPE,
    p_date_debut     IN ATTRIBUTION.date_debut%TYPE,
    p_date_fin       IN ATTRIBUTION.date_fin%TYPE,
    p_motif          IN ATTRIBUTION.motif%TYPE
) RETURN CLOB AS
BEGIN
    RETURN 'id=' || p_id
        || ';materiel_id=' || p_materiel_id
        || ';utilisateur_id=' || p_utilisateur_id
        || ';date_debut=' || TO_CHAR(p_date_debut, 'YYYY-MM-DD HH24:MI:SS')
        || ';date_fin=' || TO_CHAR(p_date_fin, 'YYYY-MM-DD HH24:MI:SS')
        || ';motif=' || p_motif;
END;
/

CREATE OR REPLACE FUNCTION serializer_equipement(
    p_id          IN EQUIPEMENT_RESEAU.id%TYPE,
    p_nom         IN EQUIPEMENT_RESEAU.nom%TYPE,
    p_type_id     IN EQUIPEMENT_RESEAU.type_id%TYPE,
    p_site_id     IN EQUIPEMENT_RESEAU.site_id%TYPE,
    p_location_id IN EQUIPEMENT_RESEAU.location_id%TYPE,
    p_adresse_mac IN EQUIPEMENT_RESEAU.adresse_mac%TYPE,
    p_adresse_ip  IN EQUIPEMENT_RESEAU.adresse_ip%TYPE
) RETURN CLOB AS
BEGIN
    RETURN 'id=' || p_id
        || ';nom=' || p_nom
        || ';type_id=' || p_type_id
        || ';site_id=' || p_site_id
        || ';location_id=' || p_location_id
        || ';adresse_mac=' || p_adresse_mac
        || ';adresse_ip=' || p_adresse_ip;
END;
/

CREATE OR REPLACE TRIGGER trg_audit_materiel
AFTER INSERT OR UPDATE OR DELETE ON MATERIEL
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        ecrire_audit(
            'MATERIEL',
            'INSERT',
            :NEW.id,
            NULL,
            serializer_materiel(:NEW.id, :NEW.numero_serie, :NEW.modele_id, :NEW.site_id,
                                :NEW.location_id, :NEW.date_achat, :NEW.statut, :NEW.etat)
        );
    ELSIF UPDATING THEN
        ecrire_audit(
            'MATERIEL',
            'UPDATE',
            :NEW.id,
            serializer_materiel(:OLD.id, :OLD.numero_serie, :OLD.modele_id, :OLD.site_id,
                                :OLD.location_id, :OLD.date_achat, :OLD.statut, :OLD.etat),
            serializer_materiel(:NEW.id, :NEW.numero_serie, :NEW.modele_id, :NEW.site_id,
                                :NEW.location_id, :NEW.date_achat, :NEW.statut, :NEW.etat)
        );
    ELSIF DELETING THEN
        ecrire_audit(
            'MATERIEL',
            'DELETE',
            :OLD.id,
            serializer_materiel(:OLD.id, :OLD.numero_serie, :OLD.modele_id, :OLD.site_id,
                                :OLD.location_id, :OLD.date_achat, :OLD.statut, :OLD.etat),
            NULL
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_audit_utilisateur
AFTER INSERT OR UPDATE OR DELETE ON UTILISATEUR
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        ecrire_audit(
            'UTILISATEUR',
            'INSERT',
            :NEW.id,
            NULL,
            serializer_utilisateur(:NEW.id, :NEW.login, :NEW.nom, :NEW.prenom, :NEW.email,
                                   :NEW.site_id, :NEW.location_id, :NEW.date_creation, :NEW.actif)
        );
    ELSIF UPDATING THEN
        ecrire_audit(
            'UTILISATEUR',
            'UPDATE',
            :NEW.id,
            serializer_utilisateur(:OLD.id, :OLD.login, :OLD.nom, :OLD.prenom, :OLD.email,
                                   :OLD.site_id, :OLD.location_id, :OLD.date_creation, :OLD.actif),
            serializer_utilisateur(:NEW.id, :NEW.login, :NEW.nom, :NEW.prenom, :NEW.email,
                                   :NEW.site_id, :NEW.location_id, :NEW.date_creation, :NEW.actif)
        );
    ELSIF DELETING THEN
        ecrire_audit(
            'UTILISATEUR',
            'DELETE',
            :OLD.id,
            serializer_utilisateur(:OLD.id, :OLD.login, :OLD.nom, :OLD.prenom, :OLD.email,
                                   :OLD.site_id, :OLD.location_id, :OLD.date_creation, :OLD.actif),
            NULL
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_audit_attribution
AFTER INSERT OR UPDATE OR DELETE ON ATTRIBUTION
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        ecrire_audit(
            'ATTRIBUTION',
            'INSERT',
            :NEW.id,
            NULL,
            serializer_attribution(:NEW.id, :NEW.materiel_id, :NEW.utilisateur_id,
                                   :NEW.date_debut, :NEW.date_fin, :NEW.motif)
        );
    ELSIF UPDATING THEN
        ecrire_audit(
            'ATTRIBUTION',
            'UPDATE',
            :NEW.id,
            serializer_attribution(:OLD.id, :OLD.materiel_id, :OLD.utilisateur_id,
                                   :OLD.date_debut, :OLD.date_fin, :OLD.motif),
            serializer_attribution(:NEW.id, :NEW.materiel_id, :NEW.utilisateur_id,
                                   :NEW.date_debut, :NEW.date_fin, :NEW.motif)
        );
    ELSIF DELETING THEN
        ecrire_audit(
            'ATTRIBUTION',
            'DELETE',
            :OLD.id,
            serializer_attribution(:OLD.id, :OLD.materiel_id, :OLD.utilisateur_id,
                                   :OLD.date_debut, :OLD.date_fin, :OLD.motif),
            NULL
        );
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_audit_equipement_reseau
AFTER INSERT OR UPDATE OR DELETE ON EQUIPEMENT_RESEAU
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        ecrire_audit(
            'EQUIPEMENT_RESEAU',
            'INSERT',
            :NEW.id,
            NULL,
            serializer_equipement(:NEW.id, :NEW.nom, :NEW.type_id, :NEW.site_id,
                                  :NEW.location_id, :NEW.adresse_mac, :NEW.adresse_ip)
        );
    ELSIF UPDATING THEN
        ecrire_audit(
            'EQUIPEMENT_RESEAU',
            'UPDATE',
            :NEW.id,
            serializer_equipement(:OLD.id, :OLD.nom, :OLD.type_id, :OLD.site_id,
                                  :OLD.location_id, :OLD.adresse_mac, :OLD.adresse_ip),
            serializer_equipement(:NEW.id, :NEW.nom, :NEW.type_id, :NEW.site_id,
                                  :NEW.location_id, :NEW.adresse_mac, :NEW.adresse_ip)
        );
    ELSIF DELETING THEN
        ecrire_audit(
            'EQUIPEMENT_RESEAU',
            'DELETE',
            :OLD.id,
            serializer_equipement(:OLD.id, :OLD.nom, :OLD.type_id, :OLD.site_id,
                                  :OLD.location_id, :OLD.adresse_mac, :OLD.adresse_ip),
            NULL
        );
    END IF;
END;
/

SHOW ERRORS PROCEDURE ecrire_audit;
SHOW ERRORS FUNCTION serializer_materiel;
SHOW ERRORS FUNCTION serializer_utilisateur;
SHOW ERRORS FUNCTION serializer_attribution;
SHOW ERRORS FUNCTION serializer_equipement;
SHOW ERRORS TRIGGER trg_audit_materiel;
SHOW ERRORS TRIGGER trg_audit_utilisateur;
SHOW ERRORS TRIGGER trg_audit_attribution;
SHOW ERRORS TRIGGER trg_audit_equipement_reseau;

EXIT;
