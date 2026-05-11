-- Populates referential tables (shared data) on Cergy node
-- Run as GLPI_OWNER on Cergy node

-- Sites
INSERT INTO SITE (code, nom, adresse) VALUES ('CERGY', 'CY Tech Cergy', '5 mail
Gay-Lussac, 95000 Cergy');
INSERT INTO SITE (code, nom, adresse) VALUES ('PAU', 'CY Tech Pau', '2 rue
Escoubet, 64000 Pau');

-- Locations (Cergy: ID 1 à5)
INSERT INTO LOCATION (site_id, batiment, etage, salle) VALUES (1, 'Bat A', 0,
'Accueil');
INSERT INTO LOCATION (site_id, batiment, etage, salle) VALUES (1, 'Bat A', 1,
'Salle 101');
INSERT INTO LOCATION (site_id, batiment, etage, salle) VALUES (1, 'Bat A', 1,
'Salle 102');
INSERT INTO LOCATION (site_id, batiment, etage, salle) VALUES (1, 'Bat B', 0,
'Datacenter');
INSERT INTO LOCATION (site_id, batiment, etage, salle) VALUES (1, 'Bat B', 1,
'Labo Reseau');
-- Locations (Pau: ID 6 à 9)
INSERT INTO LOCATION (site_id, batiment, etage, salle) VALUES (2,
'BatPrincipal', 0, 'Reception');
INSERT INTO LOCATION (site_id, batiment, etage, salle) VALUES (2,
'BatPrincipal', 1, 'Salle Info');
INSERT INTO LOCATION (site_id, batiment, etage, salle) VALUES (2,
'BatPrincipal', 1, 'Salle Reseau');
INSERT INTO LOCATION (site_id, batiment, etage, salle) VALUES (2,
'BatPrincipal', 2, 'Biblio');

-- Profils
INSERT INTO PROFIL (nom, description) VALUES ('Administrateur', 'Acces complet
au parc');
INSERT INTO PROFIL (nom, description) VALUES ('Technicien', 'Gestion des
interventions');
INSERT INTO PROFIL (nom, description) VALUES ('Utilisateur', 'Consultation et
demande');
INSERT INTO PROFIL (nom, description) VALUES ('Observateur', 'Lecture seule');
-- Groupes
INSERT INTO GROUPE (nom, description) VALUES ('DSI', 'Direction des Systemes d
Information');
INSERT INTO GROUPE (nom, description) VALUES ('Reseau', 'Equipe reseau et
telecom');
INSERT INTO GROUPE (nom, description) VALUES ('Pedagogique', 'Enseignants et
formateurs');
INSERT INTO GROUPE (nom, description) VALUES ('Administratif', 'Personnel
administratif');

-- Types de materiel
INSERT INTO TYPE_MATERIEL (libelle) VALUES ('Ordinateur portable');
INSERT INTO TYPE_MATERIEL (libelle) VALUES ('Ordinateur fixe');
INSERT INTO TYPE_MATERIEL (libelle) VALUES ('Moniteur');
INSERT INTO TYPE_MATERIEL (libelle) VALUES ('Imprimante');
INSERT INTO TYPE_MATERIEL (libelle) VALUES ('Tablette');
INSERT INTO TYPE_MATERIEL (libelle) VALUES ('Videoprojecteur');
INSERT INTO TYPE_MATERIEL (libelle) VALUES ('Scanner');
INSERT INTO TYPE_MATERIEL (libelle) VALUES ('Onduleur');

-- Constructeurs
INSERT INTO CONSTRUCTEUR (nom) VALUES ('Dell');
INSERT INTO CONSTRUCTEUR (nom) VALUES ('HP');
INSERT INTO CONSTRUCTEUR (nom) VALUES ('Lenovo');
INSERT INTO CONSTRUCTEUR (nom) VALUES ('Apple');
INSERT INTO CONSTRUCTEUR (nom) VALUES ('Cisco');
INSERT INTO CONSTRUCTEUR (nom) VALUES ('Epson');
INSERT INTO CONSTRUCTEUR (nom) VALUES ('Samsung');
INSERT INTO CONSTRUCTEUR (nom) VALUES ('APC');

-- Modeles
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (1, 1,
'Latitude 5540');
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (1, 2,
'OptiPlex 7010');
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (2, 3,
'E243d');
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (3, 1,
'ThinkPad T14');
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (4, 5,
'iPad Pro 12.9');
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (5, 1,
'Catalyst 2960');
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (6, 4,
'WorkForce WF-2860');
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (7, 3,
'SyncMaster S24');
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (8, 8,
'Smart-UPS 1500');
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (1, 1,
'XPS 15');
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (2, 1,
'EliteBook 840');
INSERT INTO MODELE (constructeur_id, type_materiel_id, reference) VALUES (5, 1,
'Catalyst 9300');

-- Types d'equipement reseau
INSERT INTO TYPE_EQUIPEMENT_RESEAU (libelle) VALUES ('Switch');
INSERT INTO TYPE_EQUIPEMENT_RESEAU (libelle) VALUES ('Routeur');
INSERT INTO TYPE_EQUIPEMENT_RESEAU (libelle) VALUES ('Point d''acces WiFi');
INSERT INTO TYPE_EQUIPEMENT_RESEAU (libelle) VALUES ('Firewall');
INSERT INTO TYPE_EQUIPEMENT_RESEAU (libelle) VALUES ('Serveur');

COMMIT;
EXIT;