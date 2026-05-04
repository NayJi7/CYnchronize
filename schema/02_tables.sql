-- schema/02_tables.sql
-- Run as GLPI_OWNER on BOTH nodes
-- 16 tables avec assignation tablespace

-- ============================================================
-- Domaine Sites & Localisation (referentiel partage)
-- ============================================================
CREATE TABLE SITE (
    id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code    VARCHAR2(10)  NOT NULL,
    nom     VARCHAR2(100) NOT NULL,
    adresse VARCHAR2(300)
) TABLESPACE TBS_REFERENTIEL;

CREATE TABLE LOCATION (
    id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    site_id  NUMBER        NOT NULL,
    batiment VARCHAR2(50)  NOT NULL,
    etage    NUMBER(2),
    salle    VARCHAR2(50)
) TABLESPACE TBS_REFERENTIEL;

-- ============================================================
-- Domaine Utilisateurs (fragmente par site)
-- ============================================================
CREATE TABLE GROUPE (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom         VARCHAR2(100) NOT NULL,
    description VARCHAR2(500)
) TABLESPACE TBS_REFERENTIEL;

CREATE TABLE PROFIL (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom         VARCHAR2(100) NOT NULL,
    description VARCHAR2(500)
) TABLESPACE TBS_REFERENTIEL;

CREATE TABLE UTILISATEUR (
    id             NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    login          VARCHAR2(50)  NOT NULL,
    nom            VARCHAR2(100) NOT NULL,
    prenom         VARCHAR2(100) NOT NULL,
    email          VARCHAR2(200) NOT NULL,
    site_id        NUMBER        NOT NULL,
    location_id    NUMBER,
    date_creation  DATE DEFAULT SYSDATE NOT NULL,
    actif          NUMBER(1) DEFAULT 1 NOT NULL
) TABLESPACE TBS_UTILISATEURS;

CREATE TABLE UTILISATEUR_GROUPE (
    utilisateur_id NUMBER NOT NULL,
    groupe_id      NUMBER NOT NULL,
    PRIMARY KEY (utilisateur_id, groupe_id)
) TABLESPACE TBS_UTILISATEURS;

CREATE TABLE UTILISATEUR_PROFIL (
    utilisateur_id NUMBER NOT NULL,
    profil_id      NUMBER NOT NULL,
    PRIMARY KEY (utilisateur_id, profil_id)
) TABLESPACE TBS_UTILISATEURS;

-- ============================================================
-- Domaine Materiels (fragmente par site)
-- ============================================================
CREATE TABLE TYPE_MATERIEL (
    id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    libelle VARCHAR2(100) NOT NULL
) TABLESPACE TBS_REFERENTIEL;

CREATE TABLE CONSTRUCTEUR (
    id  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom VARCHAR2(100) NOT NULL
) TABLESPACE TBS_REFERENTIEL;

CREATE TABLE MODELE (
    id                NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    constructeur_id   NUMBER        NOT NULL,
    type_materiel_id  NUMBER        NOT NULL,
    reference         VARCHAR2(100) NOT NULL
) TABLESPACE TBS_REFERENTIEL;

CREATE TABLE MATERIEL (
    id            NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero_serie  VARCHAR2(100) NOT NULL,
    modele_id     NUMBER        NOT NULL,
    site_id       NUMBER        NOT NULL,
    location_id   NUMBER,
    date_achat    DATE,
    statut        VARCHAR2(30) DEFAULT 'en_service' NOT NULL,
    etat          VARCHAR2(30) DEFAULT 'fonctionnel' NOT NULL
) TABLESPACE TBS_MATERIELS;

CREATE TABLE ATTRIBUTION (
    id             NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    materiel_id    NUMBER NOT NULL,
    utilisateur_id NUMBER NOT NULL,
    date_debut     DATE DEFAULT SYSDATE NOT NULL,
    date_fin       DATE,
    motif          VARCHAR2(300)
) TABLESPACE TBS_MATERIELS;

-- ============================================================
-- Domaine Reseau (fragmente par site)
-- ============================================================
CREATE TABLE TYPE_EQUIPEMENT_RESEAU (
    id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    libelle VARCHAR2(100) NOT NULL
) TABLESPACE TBS_REFERENTIEL;

CREATE TABLE EQUIPEMENT_RESEAU (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom         VARCHAR2(100) NOT NULL,
    type_id     NUMBER        NOT NULL,
    site_id     NUMBER        NOT NULL,
    location_id NUMBER,
    adresse_mac VARCHAR2(17),
    adresse_ip  VARCHAR2(15)
) TABLESPACE TBS_RESEAU;

CREATE TABLE VLAN (
    id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero  NUMBER(4)     NOT NULL,
    nom     VARCHAR2(100) NOT NULL,
    site_id NUMBER        NOT NULL
) TABLESPACE TBS_RESEAU;

CREATE TABLE PORT_RESEAU (
    id                  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    equipement_id       NUMBER     NOT NULL,
    numero              NUMBER(4)  NOT NULL,
    vlan_id             NUMBER,
    materiel_connecte_id NUMBER,
    statut              VARCHAR2(20) DEFAULT 'libre' NOT NULL
) TABLESPACE TBS_RESEAU;

-- ============================================================
-- Domaine Audit (transverse, local a chaque noeud)
-- ============================================================
CREATE TABLE JOURNAL_AUDIT (
    id                NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_concernee   VARCHAR2(50)  NOT NULL,
    operation         VARCHAR2(10)  NOT NULL,
    id_enregistrement NUMBER        NOT NULL,
    ancien_valeur     CLOB,
    nouvelle_valeur   CLOB,
    utilisateur_oracle VARCHAR2(50) DEFAULT USER NOT NULL,
    date_action       DATE DEFAULT SYSDATE NOT NULL
) TABLESPACE TBS_AUDIT;

-- Verify
SELECT table_name, tablespace_name
FROM user_tables
WHERE table_name NOT LIKE 'BIN%'
ORDER BY table_name;

EXIT;
