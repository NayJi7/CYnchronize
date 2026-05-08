-- perf/02_db_links_pau.sql
-- Run as GLPI_OWNER on Pau (port 1522)

CREATE DATABASE LINK dblink_cergy
    CONNECT TO link_user IDENTIFIED BY link123
    USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-cergy)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=FREEPDB1)))';

SELECT * FROM dual@dblink_cergy;
SELECT * FROM SITE@dblink_cergy WHERE ROWNUM = 0;

EXIT;
