-- plsql/08_curseur_batch.sql
-- Run as GLPI_OWNER on BOTH nodes

CREATE TABLE STATISTIQUES_PARC (
    id             NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    site_id        NUMBER NOT NULL,
    type_materiel  VARCHAR2(100) NOT NULL,
    etat           VARCHAR2(30) NOT NULL,
    est_obsolete   NUMBER(1) NOT NULL,
    nombre         NUMBER NOT NULL,
    date_calcul    DATE DEFAULT SYSDATE NOT NULL
) TABLESPACE TBS_AUDIT;

ALTER TABLE STATISTIQUES_PARC ADD CONSTRAINT fk_stats_site
    FOREIGN KEY (site_id) REFERENCES SITE(id);

ALTER TABLE STATISTIQUES_PARC ADD CONSTRAINT chk_stats_obsolete
    CHECK (est_obsolete IN (0, 1));

CREATE OR REPLACE PROCEDURE recalculer_statistiques_parc AS
    CURSOR c_site_materiel IS
        SELECT m.site_id,
               tm.libelle AS type_materiel,
               m.etat,
               PKG_FONCTIONS_METIER.est_obsolete(m.id) AS est_obsolete,
               COUNT(*) AS nombre
        FROM MATERIEL m
        JOIN MODELE mo ON mo.id = m.modele_id
        JOIN TYPE_MATERIEL tm ON tm.id = mo.type_materiel_id
        GROUP BY m.site_id,
                 tm.libelle,
                 m.etat,
                 PKG_FONCTIONS_METIER.est_obsolete(m.id);
BEGIN
    DELETE FROM STATISTIQUES_PARC;

    FOR r_stat IN c_site_materiel LOOP
        INSERT INTO STATISTIQUES_PARC (
            site_id,
            type_materiel,
            etat,
            est_obsolete,
            nombre,
            date_calcul
        ) VALUES (
            r_stat.site_id,
            r_stat.type_materiel,
            r_stat.etat,
            r_stat.est_obsolete,
            r_stat.nombre,
            SYSDATE
        );
    END LOOP;

    COMMIT;
END recalculer_statistiques_parc;
/

SHOW ERRORS PROCEDURE recalculer_statistiques_parc;

EXIT;
