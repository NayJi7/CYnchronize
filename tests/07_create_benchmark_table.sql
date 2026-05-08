-- tests/07_create_benchmark_table.sql
-- Run as GLPI_OWNER on BOTH nodes

CREATE TABLE RESULTAT_BENCHMARK (
    id             NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    requete_id     NUMBER(2)      NOT NULL,
    scenario       VARCHAR2(50)   NOT NULL,
    temps_ms       NUMBER(10,2)   NOT NULL,
    plan_execution CLOB,
    date_mesure    DATE DEFAULT SYSDATE NOT NULL,
    noeud          VARCHAR2(10)   NOT NULL
) TABLESPACE TBS_AUDIT;

SELECT table_name, tablespace_name FROM user_tables
WHERE table_name = 'RESULTAT_BENCHMARK';

EXIT;
