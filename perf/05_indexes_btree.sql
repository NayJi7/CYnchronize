-- perf/05_indexes_btree.sql
-- Run as GLPI_OWNER on BOTH nodes
-- Index B-Tree sur les FK les plus jointes (sélectivité forte)

CREATE INDEX IDX_ATTRIBUTION_MATERIEL
    ON ATTRIBUTION (materiel_id)
    TABLESPACE TBS_INDEX;

CREATE INDEX IDX_ATTRIBUTION_UTILISATEUR
    ON ATTRIBUTION (utilisateur_id)
    TABLESPACE TBS_INDEX;

CREATE INDEX IDX_MATERIEL_MODELE
    ON MATERIEL (modele_id)
    TABLESPACE TBS_INDEX;

CREATE INDEX IDX_PORT_EQUIPEMENT
    ON PORT_RESEAU (equipement_id)
    TABLESPACE TBS_INDEX;

SELECT index_name, table_name, index_type, uniqueness, tablespace_name
FROM user_indexes
WHERE index_name IN (
    'IDX_ATTRIBUTION_MATERIEL',
    'IDX_ATTRIBUTION_UTILISATEUR',
    'IDX_MATERIEL_MODELE',
    'IDX_PORT_EQUIPEMENT'
)
ORDER BY table_name;

EXIT;
