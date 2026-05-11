# CYnchronize

Base de données Oracle distribuée multi-sites (Cergy + Pau) — simulation GLPI.

## Démarrage rapide

```bash
# 1. Lancer les deux conteneurs Oracle
docker compose -f docker/docker-compose.yml up -d

# 2. Attendre ~60 s qu'Oracle soit prêt, puis tout initialiser
bash init.sh
```

Une fois terminé, les deux nœuds sont opérationnels avec schéma, données et benchmarks.

## Infrastructure

| Nœud | Conteneur | Port hôte | Service |
|---|---|---|---|
| Cergy | `oracle-cergy` | 1521 | `XEPDB1` |
| Pau | `oracle-pau` | 1522 | `XEPDB1` |

Réseau Docker : `oracle-net`. Image : `gvenzl/oracle-xe:21-full`.

## Comptes

| Compte | Mot de passe | Usage |
|---|---|---|
| `system` | `admin123` | DBA (création tablespaces, users) |
| `GLPI_OWNER` | `admin123` | Propriétaire de tous les objets |
| `admin_parc` | `admin123` | Démo `ROLE_ADMIN_PARC` |
| `tech_reseau` | `admin123` | Démo `ROLE_TECH_RESEAU` |
| `gestion_users` | `admin123` | Démo `ROLE_GESTION_USERS` |
| `consultant` | `admin123` | Démo `ROLE_CONSULT` |
| `auditeur` | `admin123` | Démo `ROLE_AUDITEUR` |
| `link_user` | `link123` | Comptes des database links |

## Connexions

### Depuis l'hôte (avec sqlplus installé)

```bash
sqlplus GLPI_OWNER/admin123@localhost:1521/XEPDB1   # Cergy
sqlplus GLPI_OWNER/admin123@localhost:1522/XEPDB1   # Pau
sqlplus system/admin123@localhost:1521/XEPDB1       # Cergy en tant que DBA
```

### Depuis le conteneur (sans sqlplus sur l'hôte)

```bash
docker exec -it oracle-cergy sqlplus GLPI_OWNER/admin123@XEPDB1
docker exec -it oracle-pau   sqlplus GLPI_OWNER/admin123@XEPDB1
```

### Exécuter un script

```bash
# Depuis l'hôte
sqlplus GLPI_OWNER/admin123@localhost:1521/XEPDB1 @perf/05_indexes_btree.sql

# Sans sqlplus sur l'hôte (via stdin)
docker exec -i oracle-cergy sqlplus GLPI_OWNER/admin123@XEPDB1 < perf/05_indexes_btree.sql
```

## Commandes utiles

### Vérifier l'état de l'infra

```bash
docker ps                                    # Conteneurs actifs
docker logs oracle-cergy --tail 20           # Logs Oracle
docker exec oracle-cergy bash -c "echo 'SELECT 1 FROM dual;' | sqlplus -S system/admin123@XEPDB1"
```

### Compter les données sur chaque nœud

```sql
-- À exécuter en tant que GLPI_OWNER
SELECT 'SITE' AS tbl, COUNT(*) FROM SITE
UNION ALL SELECT 'UTILISATEUR', COUNT(*) FROM UTILISATEUR
UNION ALL SELECT 'MATERIEL', COUNT(*) FROM MATERIEL
UNION ALL SELECT 'ATTRIBUTION', COUNT(*) FROM ATTRIBUTION
UNION ALL SELECT 'EQUIPEMENT_RESEAU', COUNT(*) FROM EQUIPEMENT_RESEAU
UNION ALL SELECT 'PORT_RESEAU', COUNT(*) FROM PORT_RESEAU
UNION ALL SELECT 'JOURNAL_AUDIT', COUNT(*) FROM JOURNAL_AUDIT;
```

### Tester un database link

```sql
-- Depuis Cergy
SELECT * FROM dual@dblink_pau;
SELECT COUNT(*) FROM GLPI_OWNER.MATERIEL@dblink_pau;

-- Depuis Pau
SELECT * FROM dual@dblink_cergy;
SELECT COUNT(*) FROM GLPI_OWNER.MATERIEL@dblink_cergy;
```

### Interroger la vue globale distribuée

```sql
-- Vue agrégée Cergy + Pau (lancable depuis n'importe quel nœud)
SELECT source, COUNT(*) FROM V_MATERIELS_GLOBAL GROUP BY source;
SELECT * FROM V_MATERIELS_GLOBAL WHERE etat = 'obsolete' AND ROWNUM <= 10;
```

### Rafraîchir manuellement les vues matérialisées (depuis Pau)

```sql
EXEC DBMS_MVIEW.REFRESH('MV_SITE', 'C');
EXEC DBMS_MVIEW.REFRESH('MV_MODELE', 'C');
-- ... ou via le script complet :
@tests/02_referentiels_pau_mv_refresh.sql
```

### Vérifier le job de refresh automatique (sur Pau)

```sql
SELECT job_name, state, repeat_interval, next_run_date
FROM user_scheduler_jobs;
```

### Lister les index et clusters

```sql
SELECT index_name, table_name, index_type, tablespace_name
FROM user_indexes
WHERE table_name IN ('MATERIEL', 'ATTRIBUTION', 'UTILISATEUR', 'EQUIPEMENT_RESEAU', 'PORT_RESEAU')
ORDER BY table_name, index_name;

SELECT cluster_name, tablespace_name FROM user_clusters;
SELECT table_name, cluster_name FROM user_tables WHERE cluster_name IS NOT NULL;
```

### Appeler les procédures métier

```sql
-- Attribuer un matériel à un utilisateur
EXEC PKG_ADMIN_PARC.attribuer_materiel(p_materiel_id => 100, p_utilisateur_id => 50, p_motif => 'Affectation');

-- Clôturer une attribution
EXEC PKG_ADMIN_PARC.cloturer_attribution(p_attribution_id => 1, p_motif => 'Fin de mission');

-- Transférer un matériel inter-sites (Cergy → Pau ou Pau → Cergy)
EXEC PKG_ADMIN_PARC.transferer_materiel_inter_sites(p_materiel_id => 100, p_site_dest_id => 2);

-- Générer un inventaire (curseur)
VARIABLE c REFCURSOR;
EXEC PKG_ADMIN_PARC.generer_inventaire_site(p_site_id => 1, p_cursor => :c);
PRINT c;
```

### Lancer le calcul des statistiques (curseur batch)

```sql
EXEC recalculer_statistiques_parc;
SELECT * FROM STATISTIQUES_PARC ORDER BY site_id, type_materiel;
```

### Consulter le journal d'audit

```sql
SELECT table_concernee, operation, id_enregistrement, utilisateur_oracle, date_action
FROM JOURNAL_AUDIT
ORDER BY date_action DESC
FETCH FIRST 10 ROWS ONLY;
```

## Benchmarks

### Lancer le baseline (sans index)

```bash
docker exec -i oracle-cergy sqlplus GLPI_OWNER/admin123@XEPDB1 < tests/06_benchmark_baseline.sql
docker exec -i oracle-pau   sqlplus GLPI_OWNER/admin123@XEPDB1 < tests/06_benchmark_baseline.sql
```

### Appliquer index + cluster

```bash
for f in perf/05_indexes_btree.sql perf/06_indexes_bitmap.sql \
         perf/07_indexes_composite.sql perf/08_index_functionbased.sql \
         perf/09_cluster_materiel_attribution.sql; do
  docker exec -i oracle-cergy sqlplus GLPI_OWNER/admin123@XEPDB1 < $f
  docker exec -i oracle-pau   sqlplus GLPI_OWNER/admin123@XEPDB1 < $f
done
```

### Lancer le post-index

```bash
docker exec -i oracle-cergy sqlplus GLPI_OWNER/admin123@XEPDB1 < perf/10_benchmark_post_index.sql
docker exec -i oracle-pau   sqlplus GLPI_OWNER/admin123@XEPDB1 < perf/10_benchmark_post_index.sql
```

### Comparer les résultats

```sql
SELECT requete_id, scenario, temps_ms, noeud
FROM RESULTAT_BENCHMARK
ORDER BY requete_id, scenario;
```

## Reset complet

Si tout est en vrac, repartir de zéro :

```bash
docker compose -f docker/docker-compose.yml down -v   # Supprime les volumes
docker compose -f docker/docker-compose.yml up -d     # Recrée à neuf
sleep 90                                              # Attendre Oracle
bash init.sh                                          # Réinit complète
```

## Structure du dépôt

```
docker/             docker-compose.yml + scripts d'init des conteneurs
schema/             Tablespaces, owner, tables, contraintes, rôles
plsql/              Packages (exceptions, fonctions métier, admin parc),
                    triggers (intégrité, audit), curseur batch
perf/               MV logs, db links, vues matérialisées, vues globales,
                    index (B-Tree, Bitmap, composites, function-based),
                    cluster, benchmarks
tests/              Données référentielles, opérationnelles, générateur
                    paramétrique, benchmark baseline, table de mesures
init.sh             Orchestrateur (joue tout dans le bon ordre)
RAPPORT.md          Rapport académique complet
```

## Ordre d'exécution dans `init.sh`

1. **Tablespaces** (`system`) — 6 par nœud
2. **Owner** (`system`) — création de `GLPI_OWNER`
3. **Tables** (`GLPI_OWNER`) — 17 tables
4. **Contraintes** (`GLPI_OWNER`) — FK, CHECK, UNIQUE
5. **Users / Rôles** (`system`) — 5 rôles + 5 users démo + `link_user`
6. **MV Logs** (`GLPI_OWNER` sur Cergy) — pour le FAST refresh
7. **PL/SQL** — packages, triggers, curseur batch (sur les deux nœuds)
8. **BDDR** — db links, vues matérialisées (Pau), vues globales
9. **Seed data** — référentiels Cergy, refresh MV Pau, données opérationnelles
10. **Benchmark table** — `RESULTAT_BENCHMARK`

## Troubleshooting

### Oracle ne répond pas

```bash
docker logs oracle-cergy --tail 50
# Chercher "DATABASE IS READY TO USE!" — peut prendre 60-90 s au premier démarrage
```

### Erreur `ORA-12514: TNS:listener does not currently know of service`

Vérifier le nom du service. Oracle XE 21c utilise `XEPDB1`, pas `FREEPDB1`.

### Erreur `ORA-02019: connection description for remote database not found`

Le db link n'est pas créé sur ce nœud. Relancer :
```bash
docker exec -i oracle-cergy sqlplus GLPI_OWNER/admin123@XEPDB1 < perf/01_db_links_cergy.sql
docker exec -i oracle-pau   sqlplus GLPI_OWNER/admin123@XEPDB1 < perf/02_db_links_pau.sql
```

### Erreur `ORA-04063: view has errors`

Une vue référence un objet qui a été recréé (par exemple après le cluster). Recompiler :
```sql
ALTER VIEW V_MATERIELS_GLOBAL COMPILE;
-- ou tout simplement
@perf/04_global_views_cergy.sql
@perf/04_global_views_pau.sql
```

### Erreur `ORA-04091: table is mutating`

Apparaît si on insère/modifie une table dans un trigger qui s'exécute sur cette même table. Solution : utiliser un `COMPOUND TRIGGER` (déjà fait pour `trg_unique_mac` et `trg_unique_ip`).

### Le job de refresh ne tourne pas

```sql
-- Vérifier l'état
SELECT job_name, state, last_run_date, next_run_date FROM user_scheduler_jobs;

-- Forcer un run
EXEC DBMS_SCHEDULER.RUN_JOB('JOB_REFRESH_REFERENTIEL');

-- Réactiver si désactivé
EXEC DBMS_SCHEDULER.ENABLE('JOB_REFRESH_REFERENTIEL');
```
