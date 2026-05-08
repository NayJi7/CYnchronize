-- perf/07_indexes_composite.sql
-- Run as GLPI_OWNER on BOTH nodes
-- Index B-Tree composites sur combinaisons fréquentes de filtrage

CREATE INDEX IDX_MATERIEL_SITE_STATUT
    ON MATERIEL (site_id, statut)
    TABLESPACE TBS_INDEX;

CREATE INDEX IDX_ATTRIBUTION_USER_DATEFIN
    ON ATTRIBUTION (utilisateur_id, date_fin)
    TABLESPACE TBS_INDEX;

SELECT index_name, table_name, index_type, tablespace_name
FROM user_indexes
WHERE index_name IN (
    'IDX_MATERIEL_SITE_STATUT',
    'IDX_ATTRIBUTION_USER_DATEFIN'
)
ORDER BY table_name;

EXIT;
