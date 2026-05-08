-- perf/08_index_functionbased.sql
-- Run as GLPI_OWNER on BOTH nodes
-- Index par fonction sur UPPER(login) pour recherche insensible à la casse

CREATE INDEX IDX_USER_UPPER_LOGIN
    ON UTILISATEUR (UPPER(login))
    TABLESPACE TBS_INDEX;

SELECT index_name, table_name, index_type, tablespace_name
FROM user_indexes
WHERE index_name = 'IDX_USER_UPPER_LOGIN';

EXIT;
