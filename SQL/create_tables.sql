CREATE TABLE stg.orders (
    row_id          INTEGER NOT NULL PRIMARY KEY,
    order_id        VARCHAR(50) NOT NULL,
    order_date      DATE NOT NULL,
    ship_date       DATE NOT NULL,
    ship_mode       VARCHAR(50),
    customer_id     VARCHAR(50) NOT NULL,
    customer_name   VARCHAR(100) NOT NULL,
    segment         VARCHAR(50),
    country_region  VARCHAR(100), 
    city            VARCHAR(100),
    state           VARCHAR(100),
    postal_code     VARCHAR(20),   
    region          VARCHAR(50),
    product_id      VARCHAR(50),
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    product_name    VARCHAR(500),  
    sales           NUMERIC,       
    quantity        INTEGER,       
    discount        NUMERIC,       
    profit          NUMERIC        
);

CREATE TABLE stg.people (
    regional_manager VARCHAR(100) NOT NULL, 
    region           VARCHAR(50) NOT NULL
);

CREATE TABLE stg.returns (
    returned    VARCHAR(10) NOT NULL,
    order_id    VARCHAR(50) NOT NULL
);