#!/bin/bash
set -e
echo "Setting up Cergy node..."
ORACLE_PDB=XEPDB1

sqlplus / as sysdba <<EOF
ALTER SESSION SET CONTAINER=$ORACLE_PDB;
-- Tablespace creation will be handled by schema scripts
-- opened for GLPI_OWNER
EOF
