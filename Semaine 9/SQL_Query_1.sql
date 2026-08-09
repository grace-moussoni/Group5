-- ==============================================
-- PROJET FIL ROUGE - OLIST E-COMMERCE 
-- ===============================================

-- Exercice 1 : Créer la base de données OlistCommerce

CREATE DATABASE OlistCommerce
COLLATE Latin1_General_CI_AS;
GO

-- Se positionner sur la base de données
USE OlistCommerce;
GO


-- Exercice 2 : Créer les tables "racines" 
-- =========================================

-- Table customers (Informations clients)
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(10) NOT NULL,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);
GO

-- Table sellers (Vendeurs)
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10) NOT NULL,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);
GO

-- Table products (Catalogue produits)

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm DECIMAL(8,2),
    product_height_cm DECIMAL(8,2),
    product_width_cm DECIMAL(8,2)
);
GO

-- Table product_category_name_translation (Traduction des catégories)
CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);
GO

-- =====================================================================
-- Exercice 3 : Créer les tables "dépendantes"
-- =====================================================================

-- Table orders (Commandes)
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) FOREIGN KEY REFERENCES customers(customer_id),
    order_status VARCHAR(30) NOT NULL,
    order_purchase_timestamp DATETIME NOT NULL,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME NOT NULL
);
GO

-- Table order_items (Lignes de commande)
CREATE TABLE order_items (
    order_id VARCHAR(50) FOREIGN KEY REFERENCES orders(order_id),
    order_item_id INT NOT NULL,
    product_id VARCHAR(50) FOREIGN KEY REFERENCES products(product_id),
    seller_id VARCHAR(50) FOREIGN KEY REFERENCES sellers(seller_id),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2) NOT NULL,
    freight_value DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, order_item_id)
);
GO

-- Table order_payments (Paiements)
CREATE TABLE order_payments (
    order_id VARCHAR(50) FOREIGN KEY REFERENCES orders(order_id),
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(30) NOT NULL,
    payment_installments INT,
    payment_value DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, payment_sequential)
);
GO

-- Table order_reviews (Avis clients)
CREATE TABLE order_reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) FOREIGN KEY REFERENCES orders(order_id),
    review_score INT NOT NULL, 
    review_comment_title VARCHAR(200),
    review_comment_message NVARCHAR(MAX),
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);
GO

-- =====================================================================
-- Exercice 4 : Vérifier les contraintes de order_reviews
-- =====================================================================
ALTER TABLE order_reviews 
ADD CONSTRAINT CK_order_reviews_score 
CHECK (review_score BETWEEN 1 AND 5);
GO

-- =====================================================================
-- Exercice 5 : Ajouter une colonne calculée (total_value)
-- =====================================================================
ALTER TABLE order_items 
ADD total_value AS (price + freight_value);
GO

-- ======================================================
-- Exercice 6 : Modifier la structure de products
-- ======================================================
ALTER TABLE products 
ADD product_brand VARCHAR(100),
    is_active BIT DEFAULT 1;
GO

-- ======================================================
-- Exercice 7 : Renommer et supprimer des éléments 
-- ======================================================
-- a) Créer une table temporaire test_import
CREATE TABLE test_import (
    id INT PRIMARY KEY,
    nom VARCHAR(50),
    valeur DECIMAL(10,2)
);
GO

-- b) La renommer en test_import_v2 avec sp_rename
EXEC sp_rename 'test_import', 'test_import_v2';
GO

-- c) Ajouter une colonne commentaire
ALTER TABLE test_import_v2 
ADD commentaire VARCHAR(100);
GO

-- d) La supprimer avec DROP TABLE
DROP TABLE test_import_v2;
GO

-- ===========================================
-- Exercice 8 : Créer une table d'audit
-- ============================================
CREATE TABLE order_audit (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id VARCHAR(50),
    action_type VARCHAR(20),
    action_date DATETIME DEFAULT GETDATE(),
    performed_by VARCHAR(50) DEFAULT SYSTEM_USER
);
GO

-- =================================================
-- Exercice 9 : Créer un index non-clusterisé
-- ==================================================
CREATE NONCLUSTERED INDEX IX_orders_status_date 
ON orders(order_status, order_purchase_timestamp);
GO

-- ==========================================================
-- Exercice 10 : Synthèse - Vérifier le schéma complet
-- ==========================================================
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_CATALOG = 'OlistCommerce'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO