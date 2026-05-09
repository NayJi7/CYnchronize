-- perf/01_db_links_cergy.sql
-- Run as GLPI_OWNER on Cergy (port 1521)

CREATE DATABASE LINK dblink_pau
    CONNECT TO link_user IDENTIFIED BY link123
    USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle-pau)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=FREEPDB1)))';

SELECT * FROM dual@dblink_pau;
SELECT * FROM GLPI_OWNER.SITE@dblink_pau WHERE ROWNUM = 0;

EXIT;
