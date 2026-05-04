#!/bin/bash
set -e
echo "=== CYnchronize Full Init ==="

echo "Starting Docker containers..."
docker compose -f docker/docker-compose.yml up -d

echo "Waiting for Oracle to be ready (~60s)..."
sleep 60

echo "=== Step 1: Tablespaces ==="
sqlplus system/admin123@localhost:1521/FREEPDB1 @schema/01_tablespaces_cergy.sql
sqlplus system/admin123@localhost:1522/FREEPDB1 @schema/01_tablespaces_pau.sql

echo "=== Step 2: Tables ==="
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @schema/02_tables.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @schema/02_tables.sql

echo "=== Step 3: Constraints ==="
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @schema/03_constraints.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @schema/03_constraints.sql

echo "=== Step 4: Users and Roles ==="
sqlplus system/admin123@localhost:1521/FREEPDB1 @schema/04_users_roles_cergy.sql
sqlplus system/admin123@localhost:1522/FREEPDB1 @schema/04_users_roles_pau.sql

echo "=== Step 5: MV Logs (Cergy) ==="
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @perf/00_mv_logs_cergy.sql

echo "=== Step 6: PL/SQL ==="
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @plsql/01_exceptions.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @plsql/01_exceptions.sql
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @plsql/02_pkg_fonctions_metier_spec.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @plsql/02_pkg_fonctions_metier_spec.sql
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @plsql/03_pkg_fonctions_metier_body.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @plsql/03_pkg_fonctions_metier_body.sql
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @plsql/04_pkg_admin_parc_spec.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @plsql/04_pkg_admin_parc_spec.sql
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @plsql/05_pkg_admin_parc_body.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @plsql/05_pkg_admin_parc_body.sql
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @plsql/06_triggers_integrite.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @plsql/06_triggers_integrite.sql
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @plsql/07_triggers_audit.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @plsql/07_triggers_audit.sql
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @plsql/08_curseur_batch.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @plsql/08_curseur_batch.sql

echo "=== Step 7: BDDR (db links, materialized views, global views) ==="
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @perf/01_db_links_cergy.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @perf/02_db_links_pau.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @perf/03_materialized_views_pau.sql
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @perf/04_global_views_cergy.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @perf/04_global_views_pau.sql

echo "=== Step 8: Seed Data ==="
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @tests/01_referentiels_cergy.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @tests/02_referentiels_pau_mv_refresh.sql
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @tests/03_data_cergy.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @tests/04_data_pau.sql

echo "=== Step 9: Benchmark Table ==="
sqlplus GLPI_OWNER/admin123@localhost:1521/FREEPDB1 @tests/07_create_benchmark_table.sql
sqlplus GLPI_OWNER/admin123@localhost:1522/FREEPDB1 @tests/07_create_benchmark_table.sql

echo "=== CYnchronize init complete ==="
