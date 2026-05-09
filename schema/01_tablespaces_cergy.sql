-- schema/01_tablespaces_cergy.sql
-- Run as SYSTEM on Cergy node (port 1521)
ALTER SESSION SET CONTAINER = XEPDB1;

-- Referential data (small, read-heavy)
CREATE TABLESPACE TBS_REFERENTIEL
    DATAFILE 'tbs_referentiel.dbf' SIZE 50M AUTOEXTEND ON NEXT 10M MAXSIZE 500M;

-- User data (moderate read/write)
CREATE TABLESPACE TBS_UTILISATEURS
    DATAFILE 'tbs_utilisateurs.dbf' SIZE 50M AUTOEXTEND ON NEXT 10M MAXSIZE 500M;

-- Equipment data (largest volume, heavy read/write)
CREATE TABLESPACE TBS_MATERIELS
    DATAFILE 'tbs_materiels.dbf' SIZE 100M AUTOEXTEND ON NEXT 20M MAXSIZE 1G;

-- Network data (read-heavy, small volume)
CREATE TABLESPACE TBS_RESEAU
    DATAFILE 'tbs_reseau.dbf' SIZE 50M AUTOEXTEND ON NEXT 10M MAXSIZE 500M;

-- Audit journal (append-only, growth)
CREATE TABLESPACE TBS_AUDIT
    DATAFILE 'tbs_audit.dbf' SIZE 100M AUTOEXTEND ON NEXT 20M MAXSIZE 1G;

-- All indexes separated from data
CREATE TABLESPACE TBS_INDEX
    DATAFILE 'tbs_index.dbf' SIZE 100M AUTOEXTEND ON NEXT 20M MAXSIZE 1G;

-- Verify
SELECT tablespace_name FROM dba_tablespaces WHERE tablespace_name LIKE 'TBS_%' ORDER BY tablespace_name;

EXIT;
