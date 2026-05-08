-- perf/10_benchmark_post_index.sql
-- Run as GLPI_OWNER on BOTH nodes
-- 8 requetes benchmark apres application de tous les index et du cluster

SET SERVEROUTPUT ON
SET TIMING ON

DECLARE
    v_debut  NUMBER;
    v_fin    NUMBER;
    v_temps  NUMBER;
    v_noeud  VARCHAR2(10);
BEGIN
    SELECT code INTO v_noeud FROM SITE WHERE ROWNUM = 1;

    -- Q1 : Recherche par numero de serie (cible IDX_MATERIEL --- B-Tree sur numero_serie via UK)
    v_debut := DBMS_UTILITY.GET_TIME;
    FOR r IN (SELECT id, numero_serie, statut, etat FROM MATERIEL
              WHERE numero_serie = 'SN-CG-00001') LOOP
        NULL;
    END LOOP;
    v_fin   := DBMS_UTILITY.GET_TIME;
    v_temps := (v_fin - v_debut) * 10;

    INSERT INTO RESULTAT_BENCHMARK (requete_id, scenario, temps_ms, date_mesure, noeud)
    VALUES (1, 'AVEC_INDEX_ALL', v_temps, SYSDATE, v_noeud);

    -- Q2 : Filtre multi-criteres statut + etat + site (cible Bitmap + Composite)
    v_debut := DBMS_UTILITY.GET_TIME;
    FOR r IN (SELECT id, numero_serie FROM MATERIEL
              WHERE statut = 'en_service' AND etat = 'fonctionnel' AND site_id = 1) LOOP
        NULL;
    END LOOP;
    v_fin   := DBMS_UTILITY.GET_TIME;
    v_temps := (v_fin - v_debut) * 10;

    INSERT INTO RESULTAT_BENCHMARK (requete_id, scenario, temps_ms, date_mesure, noeud)
    VALUES (2, 'AVEC_INDEX_ALL', v_temps, SYSDATE, v_noeud);

    -- Q3 : Historique materiel avec attributions (cible Cluster CL_MATERIEL_ATTRIBUTION)
    v_debut := DBMS_UTILITY.GET_TIME;
    FOR r IN (SELECT m.numero_serie, a.date_debut, a.date_fin, a.motif
              FROM MATERIEL m
              JOIN ATTRIBUTION a ON a.materiel_id = m.id
              WHERE m.site_id = 1) LOOP
        NULL;
    END LOOP;
    v_fin   := DBMS_UTILITY.GET_TIME;
    v_temps := (v_fin - v_debut) * 10;

    INSERT INTO RESULTAT_BENCHMARK (requete_id, scenario, temps_ms, date_mesure, noeud)
    VALUES (3, 'AVEC_INDEX_ALL', v_temps, SYSDATE, v_noeud);

    -- Q4 : Recherche insensible a la casse par login (cible IDX_USER_UPPER_LOGIN)
    v_debut := DBMS_UTILITY.GET_TIME;
    FOR r IN (SELECT id, login, nom, prenom FROM UTILISATEUR
              WHERE UPPER(login) = UPPER('admin.test1@cytech.fr')) LOOP
        NULL;
    END LOOP;
    v_fin   := DBMS_UTILITY.GET_TIME;
    v_temps := (v_fin - v_debut) * 10;

    INSERT INTO RESULTAT_BENCHMARK (requete_id, scenario, temps_ms, date_mesure, noeud)
    VALUES (4, 'AVEC_INDEX_ALL', v_temps, SYSDATE, v_noeud);

    -- Q5 : Materiels d'un site avec details modele/constructeur (cible IDX_MATERIEL_MODELE)
    v_debut := DBMS_UTILITY.GET_TIME;
    FOR r IN (SELECT m.numero_serie, mo.reference, c.nom
              FROM MATERIEL m
              JOIN MODELE mo       ON mo.id = m.modele_id
              JOIN CONSTRUCTEUR c  ON c.id  = mo.constructeur_id
              WHERE m.site_id = 1) LOOP
        NULL;
    END LOOP;
    v_fin   := DBMS_UTILITY.GET_TIME;
    v_temps := (v_fin - v_debut) * 10;

    INSERT INTO RESULTAT_BENCHMARK (requete_id, scenario, temps_ms, date_mesure, noeud)
    VALUES (5, 'AVEC_INDEX_ALL', v_temps, SYSDATE, v_noeud);

    -- Q6 : Materiels obsoletes tous sites via vue globale distribuee
    v_debut := DBMS_UTILITY.GET_TIME;
    FOR r IN (SELECT id, numero_serie, source FROM V_MATERIELS_GLOBAL
              WHERE etat = 'obsolete') LOOP
        NULL;
    END LOOP;
    v_fin   := DBMS_UTILITY.GET_TIME;
    v_temps := (v_fin - v_debut) * 10;

    INSERT INTO RESULTAT_BENCHMARK (requete_id, scenario, temps_ms, date_mesure, noeud)
    VALUES (6, 'AVEC_INDEX_ALL', v_temps, SYSDATE, v_noeud);

    -- Q7 : Referentiel via MV locale vs acces db link distant (comparaison BDDR)
    v_debut := DBMS_UTILITY.GET_TIME;
    FOR r IN (SELECT id, code, nom FROM MV_SITE) LOOP
        NULL;
    END LOOP;
    v_fin   := DBMS_UTILITY.GET_TIME;
    v_temps := (v_fin - v_debut) * 10;

    INSERT INTO RESULTAT_BENCHMARK (requete_id, scenario, temps_ms, date_mesure, noeud)
    VALUES (7, 'AVEC_INDEX_ALL', v_temps, SYSDATE, v_noeud);

    -- Q8 : Agregat comptage par type / statut / site (cible Bitmap)
    v_debut := DBMS_UTILITY.GET_TIME;
    FOR r IN (SELECT tm.libelle, m.statut, m.site_id, COUNT(*) AS nb
              FROM MATERIEL m
              JOIN MODELE mo       ON mo.id = m.modele_id
              JOIN TYPE_MATERIEL tm ON tm.id = mo.type_materiel_id
              GROUP BY tm.libelle, m.statut, m.site_id) LOOP
        NULL;
    END LOOP;
    v_fin   := DBMS_UTILITY.GET_TIME;
    v_temps := (v_fin - v_debut) * 10;

    INSERT INTO RESULTAT_BENCHMARK (requete_id, scenario, temps_ms, date_mesure, noeud)
    VALUES (8, 'AVEC_INDEX_ALL', v_temps, SYSDATE, v_noeud);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Benchmark AVEC_INDEX_ALL termine.');
END;
/

SELECT requete_id, scenario, temps_ms, noeud, date_mesure
FROM RESULTAT_BENCHMARK
WHERE scenario = 'AVEC_INDEX_ALL'
ORDER BY requete_id;

EXIT;
