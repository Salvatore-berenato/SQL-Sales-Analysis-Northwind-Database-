-- ============================================================
--  PROJET SQL : ANALYSE DES VENTES PAR PRODUIT - RAPPORT TRIMESTRIEL
--  Base de données : Northwind (SQLite)
--  Auteur : [Ton Nom]
--  Description : Extraction et analyse des ventes pour le dernier
--                trimestre disponible dans la base Northwind.
-- ============================================================


-- ============================================================
-- SECTION 0 : EXPLORATION DE LA BASE DE DONNÉES
-- Avant d'écrire des analyses, on explore toujours la structure
-- ============================================================

-- Voir toutes les tables disponibles dans la base
SELECT name FROM sqlite_master WHERE type = 'table';

-- Voir les 5 premières lignes de chaque table clé
SELECT * FROM Products    LIMIT 5;
SELECT * FROM Orders      LIMIT 5;
SELECT * FROM "Order Details" LIMIT 5;
SELECT * FROM Categories  LIMIT 5;
SELECT * FROM Customers   LIMIT 5;


-- ============================================================
-- SECTION 1 : VENTES TOTALES PAR PRODUIT - DERNIER TRIMESTRE
-- Problématique principale du projet
-- ============================================================

/*
  EXPLICATION :
  - On relie OrderDetails (lignes de commande) avec Orders (date) et Products (nom)
  - Le chiffre d'affaires = quantité × prix unitaire × (1 - remise)
  - On filtre sur Q4 2022 (le dernier trimestre complet de la base Northwind)
  - On trie du produit le plus vendu au moins vendu
*/

SELECT
    p.ProductName                                   AS Produit,
    SUM(od.Quantity)                                AS Quantite_Vendue,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS CA_HT_EUR
FROM "Order Details" od
JOIN Orders   o ON od.OrderID  = o.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE o.OrderDate >= '2022-10-01'
  AND o.OrderDate <  '2023-01-01'   -- Q4 2022 = octobre / novembre / décembre
GROUP BY p.ProductID, p.ProductName
ORDER BY CA_HT_EUR DESC;


-- ============================================================
-- SECTION 2 : TOP 10 PRODUITS LES PLUS RENTABLES (Q4 2022)
-- ============================================================

/*
  EXPLICATION :
  - Même logique que la section 1 mais on limite aux 10 meilleurs
  - LIMIT 10 coupe le résultat aux 10 premières lignes
  - Très utile pour un résumé exécutif dans un rapport
*/

SELECT
    p.ProductName                                                   AS Produit,
    SUM(od.Quantity)                                                AS Quantite_Vendue,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2)  AS CA_HT_EUR
FROM "Order Details" od
JOIN Orders   o ON od.OrderID  = o.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE o.OrderDate >= '2022-10-01'
  AND o.OrderDate <  '2023-01-01'
GROUP BY p.ProductID, p.ProductName
ORDER BY CA_HT_EUR DESC
LIMIT 10;


-- ============================================================
-- SECTION 3 : VENTES PAR CATÉGORIE DE PRODUIT (Q4 2022)
-- ============================================================

/*
  EXPLICATION :
  - On ajoute une jointure avec Categories pour regrouper les produits
  - Permet de voir quels rayons/familles de produits performent le mieux
  - Utile pour des décisions stratégiques (où investir, quoi réduire)
*/

SELECT
    c.CategoryName                                                  AS Categorie,
    COUNT(DISTINCT p.ProductID)                                     AS Nb_Produits,
    SUM(od.Quantity)                                                AS Quantite_Totale,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2)  AS CA_HT_EUR
FROM "Order Details" od
JOIN Orders     o ON od.OrderID   = o.OrderID
JOIN Products   p ON od.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE o.OrderDate >= '2022-10-01'
  AND o.OrderDate <  '2023-01-01'
GROUP BY c.CategoryID, c.CategoryName
ORDER BY CA_HT_EUR DESC;


-- ============================================================
-- SECTION 4 : ÉVOLUTION MENSUELLE DU CA SUR TOUTE L'ANNÉE 1997
-- ============================================================

/*
  EXPLICATION :
  - strftime('%Y-%m', ...) extrait l'année et le mois d'une date SQLite
  - Permet de visualiser la saisonnalité des ventes mois par mois
  - Indispensable pour repérer les pics et creux d'activité
*/

SELECT
    strftime('%Y-%m', o.OrderDate)                                  AS Mois,
    COUNT(DISTINCT o.OrderID)                                       AS Nb_Commandes,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2)  AS CA_HT_EUR
FROM Orders o
JOIN "Order Details" od ON o.OrderID = od.OrderID
WHERE o.OrderDate >= '2022-01-01'
  AND o.OrderDate <  '2023-01-01'
GROUP BY strftime('%Y-%m', o.OrderDate)
ORDER BY Mois ASC;


-- ============================================================
-- SECTION 5 : TOP 10 CLIENTS PAR CA (Q4 2022)
-- ============================================================

/*
  EXPLICATION :
  - On rejoint la table Customers pour récupérer les noms des entreprises
  - Identifier les meilleurs clients = logique de segmentation (analyse Pareto)
  - En B2B, souvent 20% des clients font 80% du CA (règle des 80/20)
*/

SELECT
    cu.CompanyName                                                  AS Client,
    cu.Country                                                      AS Pays,
    COUNT(DISTINCT o.OrderID)                                       AS Nb_Commandes,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2)  AS CA_HT_EUR
FROM Customers cu
JOIN Orders      o  ON cu.CustomerID = o.CustomerID
JOIN "Order Details" od ON o.OrderID    = od.OrderID
WHERE o.OrderDate >= '2022-10-01'
  AND o.OrderDate <  '2023-01-01'
GROUP BY cu.CustomerID, cu.CompanyName, cu.Country
ORDER BY CA_HT_EUR DESC
LIMIT 10;


-- ============================================================
-- SECTION 6 : PRODUITS EN ALERTE (stock faible + vendus en Q4)
-- ============================================================

/*
  EXPLICATION :
  - On repère les produits dont le stock restant est inférieur à 10 unités
  - ET qui ont été vendus pendant Q4 → risque de rupture de stock
  - Ce type d'analyse est typique dans un rapport de gestion
*/

SELECT
    p.ProductName       AS Produit,
    p.UnitsInStock      AS Stock_Restant,
    p.UnitsOnOrder      AS En_Commande_Fournisseur,
    SUM(od.Quantity)    AS Vendu_Q4
FROM Products p
JOIN "Order Details" od ON p.ProductID = od.ProductID
JOIN Orders       o  ON od.OrderID  = o.OrderID
WHERE p.UnitsInStock < 10
  AND o.OrderDate >= '2022-10-01'
  AND o.OrderDate <  '2023-01-01'
GROUP BY p.ProductID, p.ProductName, p.UnitsInStock, p.UnitsOnOrder
ORDER BY p.UnitsInStock ASC;


-- ============================================================
-- SECTION 7 : PART DE MARCHÉ PAR CATÉGORIE (% du CA total Q4)
-- ============================================================

/*
  EXPLICATION :
  - On calcule le CA de chaque catégorie DIVISÉ par le CA total × 100
  - La sous-requête (SELECT SUM...) calcule d'abord le CA global
  - ROUND(..., 1) arrondit à 1 décimale
  - Résultat = un tableau de parts de marché en pourcentage
*/

SELECT
    c.CategoryName                                                  AS Categorie,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2)  AS CA_HT_EUR,
    ROUND(
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) * 100.0
        / (
            SELECT SUM(od2.UnitPrice * od2.Quantity * (1 - od2.Discount))
            FROM "Order Details" od2
            JOIN Orders o2 ON od2.OrderID = o2.OrderID
            WHERE o2.OrderDate >= '2022-10-01'
              AND o2.OrderDate <  '2023-01-01'
        ),
    1)                                                              AS Part_Marche_PCT
FROM "Order Details" od
JOIN Orders     o  ON od.OrderID   = o.OrderID
JOIN Products   p  ON od.ProductID = p.ProductID
JOIN Categories c  ON p.CategoryID = c.CategoryID
WHERE o.OrderDate >= '2022-10-01'
  AND o.OrderDate <  '2023-01-01'
GROUP BY c.CategoryID, c.CategoryName
ORDER BY CA_HT_EUR DESC;


-- ============================================================
-- SECTION 8 : SYNTHÈSE GÉNÉRALE Q4 2022 (KPIs clés)
-- ============================================================

/*
  EXPLICATION :
  - KPI = Key Performance Indicator (indicateur clé de performance)
  - Cette requête produit UNE SEULE LIGNE résumant tout le trimestre
  - C'est typiquement ce qu'on met en haut d'un rapport de direction
*/

SELECT
    COUNT(DISTINCT o.OrderID)                                       AS Nb_Commandes,
    COUNT(DISTINCT o.CustomerID)                                    AS Nb_Clients_Actifs,
    COUNT(DISTINCT od.ProductID)                                    AS Nb_Produits_Vendus,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2)  AS CA_Total_HT_EUR,
    ROUND(
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))
        / COUNT(DISTINCT o.OrderID),
    2)                                                              AS Panier_Moyen_EUR
FROM Orders o
JOIN "Order Details" od ON o.OrderID = od.OrderID
WHERE o.OrderDate >= '2022-10-01'
  AND o.OrderDate <  '2023-01-01';
