# 📊 SQL Sales Analysis — Northwind Database

## Contexte du projet

Ce projet simule la mission d'un analyste data dans une entreprise commerciale B2B.
L'objectif est de produire un **rapport trimestriel des ventes** à destination de la direction,
en utilisant uniquement SQL pour extraire et analyser les données.

> Base de données utilisée : **Northwind SQLite** (base de référence simulant une entreprise de distribution internationale)

---

## Problématique

> *"L'entreprise souhaite produire un rapport détaillant les ventes totales par produit
> pour le dernier trimestre (Q4 2022), afin d'orienter ses décisions commerciales et logistiques."*

---

## Structure du projet

```
📁 projet-sql-northwind/
│
├── northwind_sales_analysis.sql   ← Fichier principal avec toutes les requêtes
└── README.md                      ← Ce fichier
```

---

## Analyses réalisées

| # | Analyse | Objectif |
|---|---------|----------|
| 0 | Exploration de la base | Comprendre la structure avant d'analyser |
| 1 | Ventes totales par produit (Q4) | Répondre à la problématique principale |
| 2 | Top 10 produits les plus rentables | Résumé exécutif pour la direction |
| 3 | Ventes par catégorie de produit | Vision macro par famille de produits |
| 4 | Évolution mensuelle du CA (2022) | Analyse de la saisonnalité |
| 5 | Top 10 clients par CA | Segmentation et analyse Pareto |
| 6 | Produits en alerte de stock | Analyse logistique et prévention des ruptures |
| 7 | Part de marché par catégorie (%) | Répartition du CA par segment |
| 8 | KPIs généraux Q4 2022 | Synthèse pour rapport de direction |

---

## Concepts SQL utilisés

- `SELECT`, `FROM`, `WHERE`, `GROUP BY`, `ORDER BY`, `LIMIT`
- `JOIN` (jointures entre plusieurs tables)
- Fonctions d'agrégation : `SUM()`, `COUNT()`, `AVG()`, `ROUND()`
- Sous-requêtes (calcul de part de marché)
- Fonctions de date : `strftime()` pour extraire année/mois
- Filtres sur intervalles de dates

---

## Comment utiliser ce projet

### Prérequis
- [DB Browser for SQLite](https://sqlitebrowser.org/) (gratuit)
- Le fichier `Northwind.db` ([télécharger ici](https://github.com/jpwhite3/northwind-SQLite3))

### Étapes
1. Ouvre `Northwind.db` dans DB Browser
2. Clique sur l'onglet **"Exécuter le SQL"**
3. Ouvre le fichier `northwind_sales_analysis.sql`
4. Sélectionne une requête et appuie sur **F5** pour l'exécuter

---

## Compétences démontrées

- Modélisation et lecture d'un schéma relationnel
- Écriture de requêtes SQL complexes avec jointures multiples
- Analyse de données business (CA, KPIs, saisonnalité, segmentation)
- Production d'un rapport structuré orienté décision

---

## Auteur

**Berenato Salvatore** Futur Étudiant en MSc Data & IA appliqué au Business et à la Finance

[![LinkedIn] (www.linkedin.com/in/salvatore-berenato-172a942b3)
