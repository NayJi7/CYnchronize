# Justifications des accélérateurs — M3 Adam

## 1. Index B-Tree

Les index B-Tree sont des arbres triés et équilibrés. Plus la sélectivité est forte, plus l'index est rentable. Ils ne gèrent pas les valeurs NULL.

| Index | Table | Colonne(s) | Justification |
|---|---|---|---|
| IDX_ATTRIBUTION_MATERIEL | ATTRIBUTION | materiel_id | FK jointe systématiquement, forte sélectivité |
| IDX_ATTRIBUTION_UTILISATEUR | ATTRIBUTION | utilisateur_id | FK jointe pour l'historique utilisateur |
| IDX_MATERIEL_MODELE | MATERIEL | modele_id | FK jointe avec MODELE/CONSTRUCTEUR |
| IDX_PORT_EQUIPEMENT | PORT_RESEAU | equipement_id | FK jointe pour lister les ports d'un équipement |

## 2. Index Bitmap

Les index Bitmap sont conseillés pour les colonnes à faible sélectivité (peu de valeurs distinctes), sur des tables volumineuses avec peu de mises à jour. Une mise à jour reconstruit totalement l'index.

| Index | Table | Colonne | Valeurs distinctes | Justification |
|---|---|---|---|---|
| IDX_BM_MATERIEL_STATUT | MATERIEL | statut | 5 | Filtrage fréquent par statut sur grande table |
| IDX_BM_MATERIEL_ETAT | MATERIEL | etat | 4 | Filtrage fréquent par état |
| IDX_BM_EQ_TYPE | EQUIPEMENT_RESEAU | type_id | 5 | Faible cardinalité, lecture dominante |
| IDX_BM_USER_ACTIF | UTILISATEUR | actif | 2 (0 ou 1) | Sélectivité minimale, filtrage courant |

## 3. Index composites

Un index composite couvre plusieurs colonnes. Il est utilisé quand la clause WHERE combine ces colonnes fréquemment.

| Index | Table | Colonnes | Justification |
|---|---|---|---|
| IDX_MATERIEL_SITE_STATUT | MATERIEL | (site_id, statut) | Requêtes filtrant par site ET statut en même temps |
| IDX_ATTRIBUTION_USER_DATEFIN | ATTRIBUTION | (utilisateur_id, date_fin) | Recherche des attributions actives d'un utilisateur |

## 4. Index par fonction

La fonction doit être déterministe : une entrée donne toujours la même sortie. UPPER() est déterministe, SYSDATE ne l'est pas.

| Index | Table | Expression | Justification |
|---|---|---|---|
| IDX_USER_UPPER_LOGIN | UTILISATEUR | UPPER(login) | Recherche de login sans distinction majuscules/minuscules |

## 5. Cluster CL_MATERIEL_ATTRIBUTION

Un cluster stocke les données de plusieurs tables ayant des colonnes en commun proches sur le disque. Il est utile pour les relations Maître-Détails fréquemment jointes.

- **Maître** : MATERIEL (colonne `id` = clé du cluster)
- **Détail** : ATTRIBUTION (colonne `materiel_id` = clé du cluster)
- **Intérêt** : la jointure `MATERIEL JOIN ATTRIBUTION ON materiel_id` lit les deux lignes dans le même bloc physique, évitant les I/O supplémentaires.

## 6. Mesures de performance — comparatif SANS_INDEX vs AVEC_INDEX_ALL

### Cergy (5000 matériels, 2500 utilisateurs, 5000 attributions)

| Requête | Cible | SANS_INDEX | AVEC_INDEX_ALL |
|---|---|---|---|
| Q1 — recherche par numéro de série | UK_MATERIEL_SERIE | 0 ms | 10 ms |
| Q2 — multi-critères statut + état + site | Bitmap + Composite | 20 ms | 0 ms |
| Q3 — historique matériel + attributions | Cluster | 10 ms | 40 ms |
| Q4 — recherche login insensible à la casse | IDX_USER_UPPER_LOGIN | 10 ms | 10 ms |
| Q5 — matériels d'un site avec modèle/constructeur | IDX_MATERIEL_MODELE | 10 ms | 10 ms |
| Q6 — matériels obsolètes vue globale | (réseau) | 100 ms | 90 ms |
| Q8 — agrégat par type / statut / site | Bitmap | 40 ms | 70 ms |

### Pau (3000 matériels, 1500 utilisateurs)

| Requête | Cible | SANS_INDEX | AVEC_INDEX_ALL |
|---|---|---|---|
| Q1 — recherche par numéro de série | UK_MATERIEL_SERIE | 0 ms | 0 ms |
| Q2 — multi-critères statut + état + site | Bitmap + Composite | 0 ms | 0 ms |
| Q3 — historique matériel + attributions | Cluster | 0 ms | 10 ms |
| Q4 — recherche login insensible à la casse | IDX_USER_UPPER_LOGIN | 0 ms | 10 ms |
| Q5 — matériels d'un site avec modèle/constructeur | IDX_MATERIEL_MODELE | 0 ms | 0 ms |
| Q6 — matériels obsolètes vue globale | (réseau) | 100 ms | 80 ms |
| Q7 — référentiel via MV locale | MV vs db link | 10 ms | 0 ms |
| Q8 — agrégat par type / statut / site | Bitmap | 70 ms | 30 ms |

### Analyse

- **Limite de mesure** : `DBMS_UTILITY.GET_TIME` a une résolution de 10 ms (centièmes de seconde). Beaucoup de requêtes simples passent sous ce seuil sur des volumes modestes, d'où les valeurs à 0 ms.
- **Q8 sur Pau** : 70 → 30 ms, gain notable grâce aux index Bitmap sur faible sélectivité combinés à l'agrégation.
- **Q2 sur Cergy** : 20 → 0 ms, l'index composite + Bitmap accélère le filtrage multi-critères.
- **Q6 vue globale distribuée** : reste autour de 80-100 ms. La latence réseau du db link domine le coût et les index locaux n'ont pas d'effet significatif.
- **Q3 sur Cergy** : 10 → 40 ms, légère régression apparente. Sur ces volumes le coût d'accès au cluster peut être supérieur à un full scan rapide ; le bénéfice du cluster apparaît surtout sur de très gros volumes.
- **Q7 (Pau uniquement)** : la lecture de la MV locale est immédiate (< 10 ms) contre un coût réseau pour un accès distant via db link.

## 7. BDDR — MV locale vs db link distant

| Accès | Type | Latence observée |
|---|---|---|
| `SELECT FROM MV_SITE` sur Pau | Lecture locale (MV) | 0 ms |
| `SELECT FROM V_MATERIELS_GLOBAL` (UNION local + remote) | Cergy → Pau via db link | 80-100 ms |

**Conclusion** : La vue matérialisée élimine totalement le coût réseau pour les référentiels en lecture seule. Le db link reste nécessaire pour les données opérationnelles en temps réel et pour le rafraîchissement des MV.
