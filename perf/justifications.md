# Justifications des accélérateurs — M3 Adam

## 1. Index B-Tree

Les index B-Tree sont des arbres triés et équilibrés. Plus la sélectivité est forte, plus l'index est rentable (CM2). Ils ne gèrent pas les valeurs NULL.

| Index | Table | Colonne(s) | Justification |
|---|---|---|---|
| IDX_ATTRIBUTION_MATERIEL | ATTRIBUTION | materiel_id | FK jointe systématiquement, forte sélectivité |
| IDX_ATTRIBUTION_UTILISATEUR | ATTRIBUTION | utilisateur_id | FK jointe pour l'historique utilisateur |
| IDX_MATERIEL_MODELE | MATERIEL | modele_id | FK jointe avec MODELE/CONSTRUCTEUR |
| IDX_PORT_EQUIPEMENT | PORT_RESEAU | equipement_id | FK jointe pour lister les ports d'un équipement |

## 2. Index Bitmap

Les index Bitmap sont conseillés pour les colonnes à faible sélectivité (peu de valeurs distinctes), sur des tables volumineuses avec peu de mises à jour. Une mise à jour reconstruit totalement l'index (CM2). Disponibles en version Enterprise uniquement.

| Index | Table | Colonne | Valeurs distinctes | Justification |
|---|---|---|---|---|
| IDX_BM_MATERIEL_STATUT | MATERIEL | statut | 5 | Filtrage fréquent par statut sur grande table |
| IDX_BM_MATERIEL_ETAT | MATERIEL | etat | 4 | Filtrage fréquent par état |
| IDX_BM_EQ_TYPE | EQUIPEMENT_RESEAU | type_id | 5 | Faible cardinalité, lecture dominante |
| IDX_BM_USER_ACTIF | UTILISATEUR | actif | 2 (0 ou 1) | Sélectivité minimale, filtrage courant |

## 3. Index composites

Un index composite couvre plusieurs colonnes. Il est utilisé quand la clause WHERE combine ces colonnes fréquemment (CM2).

| Index | Table | Colonnes | Justification |
|---|---|---|---|
| IDX_MATERIEL_SITE_STATUT | MATERIEL | (site_id, statut) | Requêtes filtrant par site ET statut en même temps |
| IDX_ATTRIBUTION_USER_DATEFIN | ATTRIBUTION | (utilisateur_id, date_fin) | Recherche des attributions actives d'un utilisateur |

## 4. Index par fonction

La fonction doit être déterministe : une entrée donne toujours la même sortie (CM2). UPPER() est déterministe, SYSDATE ne l'est pas.

| Index | Table | Expression | Justification |
|---|---|---|---|
| IDX_USER_UPPER_LOGIN | UTILISATEUR | UPPER(login) | Recherche de login sans distinction majuscules/minuscules |

## 5. Cluster CL_MATERIEL_ATTRIBUTION

Un cluster stocke les données de plusieurs tables ayant des colonnes en commun proches sur le disque (CM2). Il est utile pour les relations Maître-Détails fréquemment jointes.

- **Maître** : MATERIEL (colonne `id` = clé du cluster)
- **Détail** : ATTRIBUTION (colonne `materiel_id` = clé du cluster)
- **Intérêt** : la jointure `MATERIEL JOIN ATTRIBUTION ON materiel_id` lit les deux lignes dans le même bloc physique, évitant les I/O supplémentaires.

## 6. BDDR — Comparaison MV locale vs db link distant

| Accès | Type | Latence observée |
|---|---|---|
| `SELECT * FROM MV_SITE` sur Pau | Lecture locale (MV) | < 5 ms |
| `SELECT * FROM SITE@dblink_cergy` depuis Pau | Réseau + Oracle Net | > 50 ms |

**Conclusion** : La vue matérialisée élimine le coût réseau pour les référentiels en lecture seule. Le db link reste nécessaire pour les données opérationnelles en temps réel et pour le rafraîchissement des MV.
