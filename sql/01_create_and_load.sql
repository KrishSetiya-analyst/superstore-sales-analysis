-- =====================================================================
-- Superstore Sales Analysis: create the table and load the data (MySQL 8)
-- First run:  python python/clean_data.py   (creates data/superstore_clean.csv)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS superstore;
USE superstore;

DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    row_id         INT PRIMARY KEY,
    order_id       VARCHAR(20)  NOT NULL,
    order_date     DATE         NOT NULL,
    ship_date      DATE,
    ship_mode      VARCHAR(20),
    customer_id    VARCHAR(20),
    customer_name  VARCHAR(100),
    segment        VARCHAR(20),
    country        VARCHAR(50),
    city           VARCHAR(50),
    state          VARCHAR(50),
    region         VARCHAR(20),
    product_id     VARCHAR(20),
    category       VARCHAR(30),
    sub_category   VARCHAR(30),
    product_name   VARCHAR(255),
    sales          DECIMAL(10,2),
    quantity       INT,
    profit         DECIMAL(10,4),
    returns        VARCHAR(3),
    payment_mode   VARCHAR(10)
);

-- Load the cleaned CSV. Update the path to where the file is on your computer.
-- If you get error 3948/1148, run:  SET GLOBAL local_infile = 1;
-- (or use MySQL Workbench: right-click the table > Table Data Import Wizard)
LOAD DATA LOCAL INFILE 'C:/path/to/superstore-sales-analysis/data/superstore_clean.csv'
INTO TABLE sales
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Quick checks: expect 5,901 rows and 3,003 orders
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS total_orders FROM sales;
