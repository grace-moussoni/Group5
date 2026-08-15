/* ============================================================
   -- PROJET OLIST E-COMMERCE - S10
   -- Livrable complet
   -- Base de données : OlistCommerce
   ============================================================ */

USE OlistCommerce;
GO


/* ============================================================
   EXERCICE 1 - INSERTION DE 3 CLIENTS
   ============================================================ */

INSERT INTO customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
VALUES
    ('cust_test_001', 'unique_001', '20040', 'Rio de Janeiro-Test', 'RJ'),
    ('cust_test_002', 'unique_002', '01310', 'Sao Paulo-Test', 'SP'),
    ('cust_test_003', 'unique_003', '30130', 'Belo Horizonte-Test', 'MG');
GO


/* ============================================================
   EXERCICE 2 - INSERT AVEC SELECT
   ============================================================ */

INSERT INTO order_audit (
    order_id,
    action_type,
    action_date
)
SELECT
    order_id,
    'FLAGGED_CANCEL',
    GETDATE()
FROM orders
WHERE order_status = 'canceled';
GO


/* ============================================================
   EXERCICE 3a - UPDATE DES COMMANDES DE MARS 2018
   Passer de shipped à delivered
   ============================================================ */

UPDATE orders
SET order_status = 'delivered'
WHERE order_status = 'shipped'
  AND order_purchase_timestamp >= '2018-03-01'
  AND order_purchase_timestamp < '2018-04-01';
GO


/* ============================================================
   EXERCICE 3b - DESACTIVER LES PRODUITS JAMAIS COMMANDES
   ============================================================ */

UPDATE products
SET is_active = 0
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items
    WHERE order_items.product_id = products.product_id
);
GO


/* ============================================================
   EXERCICE 4a - VERIFICATION AVANT DELETE DES CLIENTS TEST
   ============================================================ */

SELECT COUNT(*) AS NombreClientsASupprimer
FROM customers
WHERE customer_id LIKE 'cust_test_%';
GO


/* Suppression des 3 clients fictifs */

DELETE FROM customers
WHERE customer_id LIKE 'cust_test_%';
GO


/* Vérification */

SELECT COUNT(*) AS ClientsTestRestants
FROM customers
WHERE customer_id LIKE 'cust_test_%';
GO


/* ============================================================
   EXERCICE 4b - VERIFICATION AVANT DELETE DES AVIS
   Avis 5 étoiles sans commentaire
   ============================================================ */

SELECT COUNT(*) AS NombreAvisASupprimer
FROM order_reviews
WHERE review_comment_message IS NULL
  AND review_score = 5;
GO


/* Suppression */

DELETE FROM order_reviews
WHERE review_comment_message IS NULL
  AND review_score = 5;
GO


/* Vérification */

SELECT COUNT(*) AS AvisRestants
FROM order_reviews
WHERE review_comment_message IS NULL
  AND review_score = 5;
GO


/* ============================================================
   PARTIE B - SELECT
   ============================================================ */


/* ============================================================
   EXERCICE 5 - EXPLORER LA VOLUMETRIE
   ============================================================ */


/* 5a - Nombre de clients distincts */

SELECT COUNT(DISTINCT customer_unique_id) AS NombreClientsDistincts
FROM customers;
GO


/* 5b - Nombre total de commandes */

SELECT COUNT(*) AS NombreCommandes
FROM orders;
GO


/* 5c - Nombre de produits distincts vendus */

SELECT COUNT(DISTINCT product_id) AS NombreProduitsVendus
FROM order_items;
GO


/* 5d - Nombre de vendeurs */

SELECT COUNT(*) AS NombreVendeurs
FROM sellers;
GO


/* ============================================================
   EXERCICE 6 - FILTRAGE AVEC WHERE
   ============================================================ */


/* 6a - Commandes annulées */

SELECT
    order_id,
    customer_id,
    order_purchase_timestamp
FROM orders
WHERE order_status = 'canceled';
GO


/* 6b - Produits de plus de 10 000 g */

SELECT
    product_id,
    product_category_name,
    product_weight_g
FROM products
WHERE product_weight_g > 10000;
GO


/* 6c - Commandes du premier semestre 2018 */

SELECT COUNT(*) AS NombreCommandesPremierSemestre
FROM orders
WHERE order_purchase_timestamp >= '2018-01-01'
  AND order_purchase_timestamp < '2018-07-01';
GO


/* ============================================================
   EXERCICE 7 - TRI ET LIMITATION
   ============================================================ */


/* 7a - 10 articles les plus chers */

SELECT TOP 10
    order_id,
    product_id,
    price
FROM order_items
ORDER BY price DESC;
GO


/* 7b - 15 dernières commandes */

SELECT TOP 15
    order_id,
    customer_id,
    order_purchase_timestamp,
    order_status
FROM orders
ORDER BY order_purchase_timestamp DESC;
GO


/* ============================================================
   EXERCICE 8 - AGREGATION AVEC GROUP BY
   ============================================================ */


/* 8a - Nombre de commandes par statut */

SELECT
    order_status,
    COUNT(*) AS NombreCommandes
FROM orders
GROUP BY order_status
ORDER BY NombreCommandes DESC;
GO


/* 8b - Top 5 des états brésiliens */

SELECT TOP 5
    customer_state,
    COUNT(*) AS NombreClients
FROM customers
GROUP BY customer_state
ORDER BY NombreClients DESC;
GO


/* 8c - Prix moyen, minimum et maximum par vendeur
       uniquement pour les vendeurs ayant plus de 20 ventes */

SELECT
    seller_id,
    COUNT(*) AS NombreVentes,
    AVG(price) AS PrixMoyen,
    MIN(price) AS PrixMinimum,
    MAX(price) AS PrixMaximum
FROM order_items
GROUP BY seller_id
HAVING COUNT(*) > 20
ORDER BY PrixMoyen DESC;
GO


/* ============================================================
   EXERCICE 9 - FONCTIONS DE DATE
   ============================================================ */


/* 9a - Les 20 livraisons les plus lentes */

SELECT TOP 20
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    DATEDIFF(
        DAY,
        order_purchase_timestamp,
        order_delivered_customer_date
    ) AS DelaiLivraisonJours
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
ORDER BY DelaiLivraisonJours DESC;
GO


/* 9b - Nombre de commandes par mois */

SELECT
    YEAR(order_purchase_timestamp) AS Annee,
    MONTH(order_purchase_timestamp) AS Mois,
    COUNT(*) AS NombreCommandes
FROM orders
GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
ORDER BY
    Annee,
    Mois;
GO


/* 9b - Mois ayant connu le plus de commandes */

SELECT TOP 1
    YEAR(order_purchase_timestamp) AS Annee,
    MONTH(order_purchase_timestamp) AS Mois,
    COUNT(*) AS NombreCommandes
FROM orders
GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
ORDER BY NombreCommandes DESC;
GO


/* ============================================================
   EXERCICE 10 - ANALYSE DES PAIEMENTS
   ============================================================ */


/* 10a - Analyse par type de paiement */

SELECT
    payment_type,
    COUNT(*) AS NombreTransactions,
    SUM(payment_value) AS TotalEncaisse,
    AVG(payment_value) AS MontantMoyen
FROM order_payments
GROUP BY payment_type
ORDER BY TotalEncaisse DESC;
GO


/* 10b - Commandes ayant utilisé plusieurs paiements */

SELECT COUNT(DISTINCT order_id) AS CommandesAvecPlusieursPaiements
FROM order_payments
WHERE payment_sequential > 1;
GO


/* 10c - Valeur totale des paiements par mois */

SELECT
    YEAR(o.order_purchase_timestamp) AS Annee,
    MONTH(o.order_purchase_timestamp) AS Mois,
    ROUND(SUM(op.payment_value), 2) AS ValeurTotaleCommandes
FROM orders AS o
INNER JOIN order_payments AS op
    ON o.order_id = op.order_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    Annee,
    Mois;
GO
