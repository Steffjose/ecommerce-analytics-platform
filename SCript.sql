

CREATE DATABASE IF NOT EXISTS ecommerce_dw;
USE ecommerce_dw;

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- DROP TABLES IF THEY EXIST (clean slate)
-- ============================================================
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS fact_delivery;
DROP TABLE IF EXISTS fact_inventory;
DROP TABLE IF EXISTS fact_marketing;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_date;

-- ============================================================
-- DIMENSION TABLES
-- ============================================================

CREATE TABLE dim_date (
    Date_Key        INT             PRIMARY KEY,
    Full_Date       DATE,
    Year            INT,
    Quarter         INT,
    Month           INT,
    Month_Name      VARCHAR(20),
    Day             INT,
    DayOfWeek       VARCHAR(20)
);

CREATE TABLE dim_customer (
    Customer_Key            INT             PRIMARY KEY,
    Customer_ID             VARCHAR(20),
    Gender                  CHAR(1),
    City                    VARCHAR(100),
    Region                  VARCHAR(50),
    Registration_Date       DATE,
    Loyalty_Tier            VARCHAR(20),
    Is_Active               TINYINT(1),
    Last_Purchase_Date      DATE,
    CLV                     DECIMAL(12,2),
    Age_Band                VARCHAR(20),
    scd_start_date          DATE            DEFAULT (CURRENT_DATE),
    scd_end_date            DATE            DEFAULT NULL,
    scd_is_current          TINYINT(1)      DEFAULT 1
);

CREATE TABLE dim_product (
    Product_Key     INT             PRIMARY KEY,
    Product_ID      VARCHAR(20),
    Category        VARCHAR(100),
    Subcategory     VARCHAR(100),
    Brand           VARCHAR(100),
    Unit_Price      DECIMAL(12,2),
    Cost_Price      DECIMAL(12,2),
    Stock_Status    VARCHAR(30),
    Launch_Date     DATE
);

-- ============================================================
-- FACT TABLES
-- ============================================================

CREATE TABLE fact_sales (
    Sales_Key           INT             PRIMARY KEY,
    Order_ID            VARCHAR(20),
    Order_Date          DATE,
    Date_Key            INT,
    Customer_Key        INT,
    Product_Key         INT,
    Quantity            INT,
    Unit_Price          DECIMAL(12,2),
    Sales_Amount        DECIMAL(14,2),
    Discount_Amount     DECIMAL(12,2),
    Net_Amount          DECIMAL(14,2),
    Payment_Type        VARCHAR(30),
    Channel             VARCHAR(50),
    Return_Flag         TINYINT(1),
    Delivery_ID         VARCHAR(20),
    Order_Month         VARCHAR(10),
    CONSTRAINT fk_fs_date     FOREIGN KEY (Date_Key)     REFERENCES dim_date(Date_Key),
    CONSTRAINT fk_fs_customer FOREIGN KEY (Customer_Key) REFERENCES dim_customer(Customer_Key),
    CONSTRAINT fk_fs_product  FOREIGN KEY (Product_Key)  REFERENCES dim_product(Product_Key)
);

CREATE TABLE fact_delivery (
    Delivery_ID             VARCHAR(20)     PRIMARY KEY,
    Order_ID                VARCHAR(20),
    Partner_Name            VARCHAR(100),
    Dispatch_Date           DATE,
    Delivery_Date           DATE,
    SLA_Target_Days         INT,
    Actual_Delivery_Days    DECIMAL(5,1),
    On_Time_Flag            TINYINT(1),
    Delivery_Status         VARCHAR(30)
);

CREATE TABLE fact_inventory (
    Inventory_ID        INT             PRIMARY KEY,
    Product_Key         INT,
    Warehouse_ID        VARCHAR(20),
    Stock_Date          DATE,
    Opening_Stock       INT,
    Closing_Stock       INT,
    Reorder_Level       INT,
    Stockout_Flag       TINYINT(1),
    CONSTRAINT fk_fi_product FOREIGN KEY (Product_Key) REFERENCES dim_product(Product_Key)
);

CREATE TABLE fact_marketing (
    Campaign_ID         VARCHAR(20)     PRIMARY KEY,
    Start_Date          DATE,
    End_Date            DATE,
    Channel             VARCHAR(50),
    Audience_Size       INT,
    Conversions         INT,
    Spend_Amount        DECIMAL(14,2),
    Revenue_Generated   DECIMAL(14,2),
    CAC                 DECIMAL(10,2)
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_fs_date        ON fact_sales(Date_Key);
CREATE INDEX idx_fs_customer    ON fact_sales(Customer_Key);
CREATE INDEX idx_fs_product     ON fact_sales(Product_Key);
CREATE INDEX idx_fs_return      ON fact_sales(Return_Flag);
CREATE INDEX idx_fs_channel     ON fact_sales(Channel);
CREATE INDEX idx_fd_order       ON fact_delivery(Order_ID);
CREATE INDEX idx_fd_status      ON fact_delivery(Delivery_Status);
CREATE INDEX idx_fd_partner     ON fact_delivery(Partner_Name);
CREATE INDEX idx_fi_product     ON fact_inventory(Product_Key);
CREATE INDEX idx_fi_stockout    ON fact_inventory(Stockout_Flag);
CREATE INDEX idx_fi_warehouse   ON fact_inventory(Warehouse_ID);
CREATE INDEX idx_fm_channel     ON fact_marketing(Channel);
CREATE INDEX idx_cust_region    ON dim_customer(Region);
CREATE INDEX idx_cust_tier      ON dim_customer(Loyalty_Tier);
CREATE INDEX idx_prod_category  ON dim_product(Category);

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- LOAD DATA FROM CSV FILES
-- Change the path to your actual CSV folder path
-- Windows example: C:/Users/steff/Downloads/
-- ============================================================

LOAD DATA LOCAL INFILE 'C:/your-path/Date.csv'
INTO TABLE dim_date
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Date_Key, Full_Date, Year, Quarter, Month, Month_Name, Day, DayOfWeek);

LOAD DATA LOCAL INFILE 'C:/your-path/Customer.csv'
INTO TABLE dim_customer
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Customer_Key, Customer_ID, Gender, City, Region, Registration_Date,
 Loyalty_Tier, Is_Active, Last_Purchase_Date, CLV, Age_Band);

LOAD DATA LOCAL INFILE 'C:/your-path/Product.csv'
INTO TABLE dim_product
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Product_Key, Product_ID, Category, Subcategory, Brand,
 Unit_Price, Cost_Price, Stock_Status, Launch_Date);

LOAD DATA LOCAL INFILE 'C:/your-path/Sales.csv'
INTO TABLE fact_sales
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Sales_Key, Order_ID, Order_Date, Date_Key, Customer_Key, Product_Key,
 Quantity, Unit_Price, Sales_Amount, Discount_Amount, Net_Amount,
 Payment_Type, Channel, Return_Flag, Delivery_ID, Order_Month);

LOAD DATA LOCAL INFILE 'C:/your-path/Delivery.csv'
INTO TABLE fact_delivery
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Delivery_ID, Order_ID, Partner_Name, Dispatch_Date, Delivery_Date,
 SLA_Target_Days, Actual_Delivery_Days, On_Time_Flag, Delivery_Status);

LOAD DATA LOCAL INFILE 'C:/your-path/Inventory.csv'
INTO TABLE fact_inventory
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Inventory_ID, Product_Key, Warehouse_ID, Stock_Date,
 Opening_Stock, Closing_Stock, Reorder_Level, Stockout_Flag);

LOAD DATA LOCAL INFILE 'C:/your-path/Marketing.csv'
INTO TABLE fact_marketing
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Campaign_ID, Start_Date, End_Date, Channel, Audience_Size,
 Conversions, Spend_Amount, Revenue_Generated, CAC);

-- ============================================================
-- VERIFY ROW COUNTS
-- ============================================================
SELECT 'dim_date'       AS table_name, COUNT(*) AS row_count FROM dim_date
UNION ALL
SELECT 'dim_customer',  COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_product',   COUNT(*) FROM dim_product
UNION ALL
SELECT 'fact_sales',    COUNT(*) FROM fact_sales
UNION ALL
SELECT 'fact_delivery', COUNT(*) FROM fact_delivery
UNION ALL
SELECT 'fact_inventory',COUNT(*) FROM fact_inventory
UNION ALL
SELECT 'fact_marketing',COUNT(*) FROM fact_marketing;

-- ============================================================
-- EXPECTED OUTPUT
-- dim_date        365
-- dim_customer    5,000
-- dim_product     1,000
-- fact_sales      50,000
-- fact_delivery   50,000
-- fact_inventory  13,250
-- fact_marketing  120
-- ============================================================