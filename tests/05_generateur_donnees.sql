-- Parametric data generator: peupler_tout(p_ratio)
-- Run on BOTH nodes after referential data is loaded

CREATE OR REPLACE PROCEDURE peupler_tout(p_ratio IN NUMBER DEFAULT 1) AS
v_nb_users NUMBER := FLOOR(2500 * p_ratio);
v_nb_materiels NUMBER := FLOOR(5000 * p_ratio);
v_nb_equip NUMBER := FLOOR(500 * p_ratio);
v_site_id NUMBER;
v_prefix VARCHAR2(5);
v_ip_prefix VARCHAR2(6);
BEGIN

-- Determine site
BEGIN
SELECT id, code INTO v_site_id, v_prefix FROM SITE WHERE ROWNUM = 1;
EXCEPTION WHEN OTHERS THEN
SELECT id, code INTO v_site_id, v_prefix FROM MV_SITE WHERE ROWNUM = 1;
END;
IF v_prefix = 'PAU' THEN v_ip_prefix := '10.2.'; ELSE v_ip_prefix :=
'10.1.'; END IF;

-- Generate users
FOR i IN 1..v_nb_users LOOP
INSERT INTO UTILISATEUR (login, nom, prenom, email, site_id,
location_id, actif)
VALUES ('user' || v_prefix || '_' || i, 'Nom' || i, 'Prenom' || i,
'user_' || v_prefix || '_' || i || '@cytech.fr', v_site_id, MOD(i, 5) + 1, CASE
WHEN MOD(i, 20) = 0 THEN 0 ELSE 1 END);
END LOOP;

-- Generate materiels
FOR i IN 1..v_nb_materiels LOOP
INSERT INTO MATERIEL (numero_serie, modele_id, site_id, location_id,
date_achat, statut, etat)
VALUES ('SN-' || v_prefix || '-' || LPAD(i, 6, '0'), MOD(i, 11) + 1,
v_site_id, MOD(i, 5) + 1, ADD_MONTHS(SYSDATE, -MOD(i*7, 120)), 'en_service',
'fonctionnel');
END LOOP;
COMMIT;
DBMS_OUTPUT.PUT_LINE('Generated ' || v_nb_users || ' users for ' ||
v_prefix);
END;
/
EXIT;