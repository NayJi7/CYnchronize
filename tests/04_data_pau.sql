-- Populates operational data for PAU site (site_id = 2)
-- Run as GLPI_OWNER on Pau node

-- VLANS Pau
INSERT INTO VLAN (numero, nom, site_id) VALUES (10, 'VLAN_Etudiants', 2);
INSERT INTO VLAN (numero, nom, site_id) VALUES (20, 'VLAN_Personnel', 2);
INSERT INTO VLAN (numero, nom, site_id) VALUES (30, 'VLAN_Administration', 2);
INSERT INTO VLAN (numero, nom, site_id) VALUES (40, 'VLAN_Serveurs', 2);

-- Utilisateurs Pau
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
FOR i IN 1..1500 LOOP
INSERT INTO UTILISATEUR (login, nom, prenom, email, site_id,
location_id, actif)
VALUES (
LOWER(v_prenoms(MOD(i-1, 30) + 1) || '.' || v_noms(MOD(i-1, 20) +
1) || 'p' || i),
v_noms(MOD(i-1, 20) + 1),
v_prenoms(MOD(i-1, 30) + 1),
LOWER(v_prenoms(MOD(i-1, 30) + 1) || '.' || v_noms(MOD(i-1, 20) +
1) || 'p' || i) || '@cytech.fr',
2,
MOD(i, 4) + 6,
CASE WHEN MOD(i, 15) = 0 THEN 0 ELSE 1 END
);
END LOOP;
COMMIT;
END;
/

-- Materiels Pau (3000 items)
DECLARE
v_modele_ids SYS.ODCINUMBERLIST;
v_statuts SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('en_service',
'en_stock', 'en_reparation', 'reforme', 'pret');
v_etats SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST('fonctionnel',
'defectueux', 'obsolete', 'neuf');
BEGIN
SELECT id BULK COLLECT INTO v_modele_ids FROM MV_MODELE;
FOR i IN 1..3000 LOOP

INSERT INTO MATERIEL (numero_serie, modele_id, site_id, location_id,
date_achat, statut, etat)
VALUES (
'SN-PA-' || LPAD(i, 5, '0'),
v_modele_ids(MOD(i-1, v_modele_ids.COUNT) + 1),
2,
MOD(i, 4) + 6,
ADD_MONTHS(SYSDATE, -MOD(i*7, 120)),
v_statuts(MOD(i*3, 5) + 1),
v_etats(MOD(i*5, 4) + 1)
);
END LOOP;
COMMIT;
END;
/
EXIT;