sudo docker exec -i oracle-pau sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 <<EOF
SET TIMING ON;
SET SERVEROUTPUT ON;

-- 1. On s'assure que la table de résultats est prête
TRUNCATE TABLE RESULTAT_BENCHMARK;

-- Q1 : Recherche (Version robuste)
DECLARE
    v_start NUMBER; v_end NUMBER; v_count NUMBER;
BEGIN
    v_start := DBMS_UTILITY.GET_TIME;
    -- On cherche n'importe quel numéro de série au lieu d'un fixe
    SELECT COUNT(*) INTO v_count FROM MATERIEL WHERE numero_serie LIKE 'SN-%';
    v_end := DBMS_UTILITY.GET_TIME;
    INSERT INTO RESULTAT_BENCHMARK (requete_id, scenario, temps_ms, noeud)
    VALUES ('Q1', 'SANS_INDEX', (v_end - v_start) * 10, 'PAU');
END;
/

-- Q4 : Recherche Login (Version robuste)
DECLARE
    v_start NUMBER; v_end NUMBER; v_count NUMBER;
BEGIN
    v_start := DBMS_UTILITY.GET_TIME;
    SELECT COUNT(*) INTO v_count FROM UTILISATEUR WHERE UPPER(login) LIKE '%ADMIN%';
    v_end := DBMS_UTILITY.GET_TIME;
    INSERT INTO RESULTAT_BENCHMARK (requete_id, scenario, temps_ms, noeud)
    VALUES ('Q4', 'SANS_INDEX', (v_end - v_start) * 10, 'PAU');
END;
/

-- Q6 : Global (On recrée la vue juste avant au cas où)
CREATE OR REPLACE VIEW V_MATERIELS_GLOBAL AS SELECT * FROM MATERIEL UNION ALL SELECT * FROM MATERIEL@dblink_pau;

DECLARE
    v_start NUMBER; v_end NUMBER; v_count NUMBER;
BEGIN
    v_start := DBMS_UTILITY.GET_TIME;
    SELECT COUNT(*) INTO v_count FROM V_MATERIELS_GLOBAL;
    v_end := DBMS_UTILITY.GET_TIME;
    INSERT INTO RESULTAT_BENCHMARK (requete_id, scenario, temps_ms, noeud)
    VALUES ('Q6', 'GLOBAL', (v_end - v_start) * 10, 'PAU');
END;
/

COMMIT;

-- AFFICHAGE DES RÉSULTATS
COLUMN requete_id FORMAT A10;
COLUMN scenario FORMAT A15;
SELECT requete_id, scenario, temps_ms FROM RESULTAT_BENCHMARK;
EOF