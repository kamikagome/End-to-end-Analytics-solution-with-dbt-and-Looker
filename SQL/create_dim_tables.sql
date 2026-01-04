CREATE SCHEMA IF NOT EXISTS dwh;

-- 1. DIMENSION: PRODUCTS
DROP TABLE IF EXISTS dwh.dim_product;
CREATE TABLE dwh.dim_product (
    id SERIAL PRIMARY KEY,
    product_id VARCHAR(50),
    product_name VARCHAR(500),
    category VARCHAR(50),
    sub_category VARCHAR(50)
);

-- 2. DIMENSION: CUSTOMERS
DROP TABLE IF EXISTS dwh.dim_customer;
CREATE TABLE dwh.dim_customer (
    customer_id VARCHAR(50) NOT NULL PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50)
);

-- 3. DIMENSION: SHIPPING
DROP TABLE IF EXISTS dwh.dim_shipping;
CREATE TABLE dwh.dim_shipping (
    id SERIAL PRIMARY KEY,
    ship_mode VARCHAR(50)
);

-- 4. DIMENSION: GEOGRAPHY
DROP TABLE IF EXISTS dwh.dim_geo;
CREATE TABLE dwh.dim_geo (
    id SERIAL PRIMARY KEY,
    country_region VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    regional_manager VARCHAR(100)
);
