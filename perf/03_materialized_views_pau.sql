-- perf/03_materialized_views_pau.sql
-- Run as GLPI_OWNER on Pau (port 1522)

CREATE MATERIALIZED VIEW MV_SITE
    BUILD IMMEDIATE
    REFRESH FAST ON DEMAND
    WITH PRIMARY KEY
    AS SELECT * FROM SITE@dblink_cergy;

CREATE MATERIALIZED VIEW MV_LOCATION
    BUILD IMMEDIATE
    REFRESH FAST ON DEMAND
    WITH PRIMARY KEY
    AS SELECT * FROM LOCATION@dblink_cergy;

CREATE MATERIALIZED VIEW MV_TYPE_MATERIEL
    BUILD IMMEDIATE
    REFRESH FAST ON DEMAND
    WITH PRIMARY KEY
    AS SELECT * FROM TYPE_MATERIEL@dblink_cergy;

CREATE MATERIALIZED VIEW MV_CONSTRUCTEUR
    BUILD IMMEDIATE
    REFRESH FAST ON DEMAND
    WITH PRIMARY KEY
    AS SELECT * FROM CONSTRUCTEUR@dblink_cergy;

CREATE MATERIALIZED VIEW MV_MODELE
    BUILD IMMEDIATE
    REFRESH FAST ON DEMAND
    WITH PRIMARY KEY
    AS SELECT * FROM MODELE@dblink_cergy;

CREATE MATERIALIZED VIEW MV_TYPE_EQUIPEMENT_RESEAU
    BUILD IMMEDIATE
    REFRESH FAST ON DEMAND
    WITH PRIMARY KEY
    AS SELECT * FROM TYPE_EQUIPEMENT_RESEAU@dblink_cergy;

CREATE MATERIALIZED VIEW MV_GROUPE
    BUILD IMMEDIATE
    REFRESH FAST ON DEMAND
    WITH PRIMARY KEY
    AS SELECT * FROM GROUPE@dblink_cergy;

CREATE MATERIALIZED VIEW MV_PROFIL
    BUILD IMMEDIATE
    REFRESH FAST ON DEMAND
    WITH PRIMARY KEY
    AS SELECT * FROM PROFIL@dblink_cergy;

BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_REFRESH_REFERENTIEL',
        job_type        => 'PLSQL_BLOCK',
        job_action      => '
            BEGIN
                DBMS_MVIEW.REFRESH(''MV_SITE'',                   ''C'');
                DBMS_MVIEW.REFRESH(''MV_LOCATION'',               ''C'');
                DBMS_MVIEW.REFRESH(''MV_TYPE_MATERIEL'',          ''C'');
                DBMS_MVIEW.REFRESH(''MV_CONSTRUCTEUR'',           ''C'');
                DBMS_MVIEW.REFRESH(''MV_MODELE'',                 ''C'');
                DBMS_MVIEW.REFRESH(''MV_TYPE_EQUIPEMENT_RESEAU'', ''C'');
                DBMS_MVIEW.REFRESH(''MV_GROUPE'',                 ''C'');
                DBMS_MVIEW.REFRESH(''MV_PROFIL'',                 ''C'');
            END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=HOURLY',
        enabled         => TRUE,
        comments        => 'Rafraichissement toutes les heures des MV referentielles depuis Cergy'
    );
END;
/

SELECT mview_name, refresh_mode, refresh_method, last_refresh_date
FROM user_mviews
ORDER BY mview_name;

EXIT;
