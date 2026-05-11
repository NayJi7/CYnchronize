-- Populates operational data for CERGY site (site_id = 1)
-- Run as GLPI_OWNER on Cergy node

-- VLANS Cergy
INSERT INTO VLAN (numero, nom, site_id) VALUES (10, 'VLAN_Etudiants', 1);
INSERT INTO VLAN (numero, nom, site_id) VALUES (20, 'VLAN_Personnel', 1);
INSERT INTO VLAN (numero, nom, site_id) VALUES (30, 'VLAN_Administration', 1);
INSERT INTO VLAN (numero, nom, site_id) VALUES (40, 'VLAN_Serveurs', 1);
INSERT INTO VLAN (numero, nom, site_id) VALUES (50, 'VLAN_Imprimantes', 1);

-- Utilisateurs Cergy
DECLARE
v_prenoms SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('Jean', 'Marie',
'Pierre', 'Sophie', 'Luc', 'Claire', 'Paul', 'Anne', 'Marc', 'Isabelle',
'Thomas', 'Julie', 'Nicolas', 'Laura', 'Antoine', 'Fabien', 'Camille',
'Julien', 'Lea', 'Romain', 'Emma', 'David', 'Sarah', 'Mathieu', 'Chloe',
'Alexandre', 'Juliette', 'Guillaume', 'Manon', 'Lucas');
v_noms SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('Martin', 'Bernard',
'Dubois', 'Thomas', 'Robert', 'Richard', 'Petit', 'Durand', 'Leroy', 'Moreau',
'Simon', 'Laurent', 'Lefebvre', 'Michel', 'Garcia', 'David', 'Bertrand',
'Roux', 'Vincent', 'Fournier');
BEGIN
FOR i IN 1..2500 LOOP
INSERT INTO UTILISATEUR (login, nom, prenom, email, site_id,
location_id, actif)
VALUES (
LOWER(v_prenoms(MOD(i-1, 30) + 1) || '.' || v_noms(MOD(i-1, 20) +
1) || i),
v_noms(MOD(i-1, 20) + 1),
v_prenoms(MOD(i-1, 30) + 1),
LOWER(v_prenoms(MOD(i-1, 30) + 1) || '.' || v_noms(MOD(i-1, 20) +
1) || i) || '@cytech.fr',
1,
MOD(i, 5) + 1,
CASE WHEN MOD(i, 20) = 0 THEN 0 ELSE 1 END
);
END LOOP;
COMMIT;
END;
/

-- Equipements reseau Cergy
DECLARE
v_types SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(1, 1, 1, 1, 2, 3, 3, 4,
5);
BEGIN
FOR i IN 1..500 LOOP
INSERT INTO EQUIPEMENT_RESEAU (nom, type_id, site_id, location_id,
adresse_mac, adresse_ip)
VALUES (

'EQ-CERGY-' || LPAD(i, 4, '0'),
v_types(MOD(i-1, 9) + 1),
1,
MOD(i, 5) + 1,
'00:1A:2B:3C:' || TO_CHAR(TRUNC((i-1)/256), 'FM0X') || ':' ||
TO_CHAR(MOD(i-1, 256), 'FM0X'),
'10.1.' || TRUNC((i-1)/250) || '.' || MOD(i-1, 250)
);
END LOOP;
COMMIT;
END;
/

-- Ports reseau
DECLARE
v_nb_ports NUMBER := 24;
v_vlan_ids SYS.ODCINUMBERLIST;
BEGIN
SELECT id BULK COLLECT INTO v_vlan_ids FROM VLAN WHERE site_id = 1 ORDER BY numero;
FOR eq_rec IN (SELECT id FROM EQUIPEMENT_RESEAU WHERE site_id = 1) LOOP
FOR p IN 1..v_nb_ports LOOP
INSERT INTO PORT_RESEAU (equipement_id, numero, vlan_id, statut)
VALUES (
eq_rec.id, p,
v_vlan_ids(CASE WHEN p<=8 THEN 1 WHEN p<=16 THEN 2 WHEN p<=20 THEN 3
WHEN p<=22 THEN 4 ELSE 5 END),
CASE WHEN MOD(eq_rec.id + p, 3) = 0 THEN 'libre' ELSE 'utilise'
END
);
END LOOP;
END LOOP;
COMMIT;
END;
/

-- Materiels Cergy
DECLARE
v_modele_ids SYS.ODCINUMBERLIST;
v_statuts SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('en_service',
'en_stock', 'en_reparation', 'reforme', 'pret');
v_etats SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('fonctionnel',
'defectueux', 'obsolete', 'neuf');
BEGIN
SELECT id BULK COLLECT INTO v_modele_ids FROM MODELE;
FOR i IN 1..5000 LOOP
INSERT INTO MATERIEL (numero_serie, modele_id, site_id, location_id,
date_achat, statut, etat)
VALUES (
'SN-CG-' || LPAD(i, 5, '0'),
v_modele_ids(MOD(i-1, v_modele_ids.COUNT) + 1),
1,
MOD(i, 5) + 1,
ADD_MONTHS(SYSDATE, -MOD(i*7, 120)),
v_statuts(MOD(i*3, 5) + 1),
v_etats(MOD(i*5, 4) + 1)

);
END LOOP;
COMMIT;
END;
/

-- Attributions
DECLARE
v_mat_ids  SYS.ODCINUMBERLIST;
v_user_ids SYS.ODCINUMBERLIST;
BEGIN
SELECT id BULK COLLECT INTO v_mat_ids  FROM MATERIEL    WHERE site_id = 1;
SELECT id BULK COLLECT INTO v_user_ids FROM UTILISATEUR WHERE site_id = 1;

-- 3000 active
FOR i IN 1..3000 LOOP
INSERT INTO ATTRIBUTION (materiel_id, utilisateur_id, date_debut,
date_fin, motif)
VALUES (v_mat_ids(i), v_user_ids(MOD(i*7, v_user_ids.COUNT) + 1),
ADD_MONTHS(SYSDATE, -MOD(i*11, 24)), NULL, 'Attribution initiale');
END LOOP;
-- 2000 closed

FOR i IN 3001..5000 LOOP
INSERT INTO ATTRIBUTION (materiel_id, utilisateur_id, date_debut,
date_fin, motif)
VALUES (v_mat_ids(MOD(i-1, v_mat_ids.COUNT) + 1),
v_user_ids(MOD(i*13, v_user_ids.COUNT) + 1),
ADD_MONTHS(SYSDATE, -24 - MOD(i*17, 24)), ADD_MONTHS(SYSDATE, -MOD(i*7, 12)),
'Remplacement');
END LOOP;
COMMIT;
END;
/
EXIT;