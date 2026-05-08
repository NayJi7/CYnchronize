-- perf/06_indexes_bitmap.sql
-- Run as GLPI_OWNER on BOTH nodes
-- Index Bitmap sur colonnes à faible sélectivité (peu de valeurs différentes)
-- Remarque : index Bitmap disponible en version Enterprise uniquement (CM2)

CREATE BITMAP INDEX IDX_BM_MATERIEL_STATUT
    ON MATERIEL (statut)
    TABLESPACE TBS_INDEX;

CREATE BITMAP INDEX IDX_BM_MATERIEL_ETAT
    ON MATERIEL (etat)
    TABLESPACE TBS_INDEX;

CREATE BITMAP INDEX IDX_BM_EQ_TYPE
    ON EQUIPEMENT_RESEAU (type_id)
    TABLESPACE TBS_INDEX;

CREATE BITMAP INDEX IDX_BM_USER_ACTIF
    ON UTILISATEUR (actif)
    TABLESPACE TBS_INDEX;

SELECT index_name, table_name, index_type, tablespace_name
FROM user_indexes
WHERE index_name IN (
    'IDX_BM_MATERIEL_STATUT',
    'IDX_BM_MATERIEL_ETAT',
    'IDX_BM_EQ_TYPE',
    'IDX_BM_USER_ACTIF'
)
ORDER BY table_name;

EXIT;
