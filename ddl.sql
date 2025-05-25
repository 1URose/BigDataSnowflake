BEGIN;

DROP TABLE IF EXISTS mock_data;
CREATE TABLE mock_data (
  id                   INT,
  customer_first_name  TEXT,
  customer_last_name   TEXT,
  customer_age         INT,
  customer_email       TEXT,
  customer_country     TEXT,
  customer_postal_code TEXT,
  customer_pet_type    TEXT,
  customer_pet_name    TEXT,
  customer_pet_breed   TEXT,
  seller_first_name    TEXT,
  seller_last_name     TEXT,
  seller_email         TEXT,
  seller_country       TEXT,
  seller_postal_code   TEXT,
  product_name         TEXT,
  product_category     TEXT,
  product_price        NUMERIC,
  product_quantity     INT,
  sale_date            TEXT,
  sale_customer_id     INT,
  sale_seller_id       INT,
  sale_product_id      INT,
  sale_quantity        INT,
  sale_total_price     NUMERIC,
  store_name           TEXT,
  store_location       TEXT,
  store_city           TEXT,
  store_state          TEXT,
  store_country        TEXT,
  store_phone          TEXT,
  store_email          TEXT,
  pet_category         TEXT,
  product_weight       NUMERIC,
  product_color        TEXT,
  product_size         TEXT,
  product_brand        TEXT,
  product_material     TEXT,
  product_description  TEXT,
  product_rating       NUMERIC,
  product_reviews      INT,
  product_release_date TEXT,
  product_expiry_date  TEXT,
  supplier_name        TEXT,
  supplier_contact     TEXT,
  supplier_email       TEXT,
  supplier_phone       TEXT,
  supplier_address     TEXT,
  supplier_city        TEXT,
  supplier_country     TEXT
);

DROP TABLE IF EXISTS dim_countries;
CREATE TABLE dim_countries (
  country_id   BIGSERIAL PRIMARY KEY,
  country_name TEXT       NOT NULL UNIQUE
);

DROP TABLE IF EXISTS dim_cities;
CREATE TABLE dim_cities (
  city_id   BIGSERIAL PRIMARY KEY,
  city_name TEXT       NOT NULL UNIQUE
);

DROP TABLE IF EXISTS dim_dates;
CREATE TABLE dim_dates (
  date_id    BIGSERIAL PRIMARY KEY,
  full_date  DATE       NOT NULL UNIQUE,
  year       INT        NOT NULL,
  quarter    INT        NOT NULL,
  month      INT        NOT NULL,
  day        INT        NOT NULL,
  weekday    TEXT       NOT NULL
);

DROP TABLE IF EXISTS dim_pet_types;
CREATE TABLE dim_pet_types (
  pet_type_id   BIGSERIAL PRIMARY KEY,
  pet_type_name TEXT       NOT NULL UNIQUE
);
DROP TABLE IF EXISTS dim_pet_breeds;
CREATE TABLE dim_pet_breeds (
  pet_breed_id   BIGSERIAL PRIMARY KEY,
  pet_breed_name TEXT       NOT NULL UNIQUE
);
DROP TABLE IF EXISTS dim_pet_categories;
CREATE TABLE dim_pet_categories (
  pet_category_id   BIGSERIAL PRIMARY KEY,
  pet_category_name TEXT       NOT NULL UNIQUE
);

DROP TABLE IF EXISTS dim_pets;
CREATE TABLE dim_pets (
  pet_id          BIGSERIAL PRIMARY KEY,
  pet_name        TEXT       NOT NULL,
  pet_type_id     BIGINT     NOT NULL REFERENCES dim_pet_types(pet_type_id),
  pet_breed_id    BIGINT     REFERENCES dim_pet_breeds(pet_breed_id),
  pet_category_id BIGINT     REFERENCES dim_pet_categories(pet_category_id),
  UNIQUE(pet_name, pet_type_id)
);

DROP TABLE IF EXISTS dim_suppliers;
CREATE TABLE dim_suppliers (
  supplier_id     BIGSERIAL PRIMARY KEY,
  supplier_name   TEXT       NOT NULL,
  contact_person  TEXT,
  supplier_email  TEXT       UNIQUE,
  supplier_phone  TEXT,
  supplier_address TEXT,
  city_id         BIGINT     REFERENCES dim_cities(city_id),
  country_id      BIGINT     REFERENCES dim_countries(country_id)
);

DROP TABLE IF EXISTS dim_product_categories;
CREATE TABLE dim_product_categories (
  category_id   BIGSERIAL PRIMARY KEY,
  category_name TEXT       NOT NULL UNIQUE
);
DROP TABLE IF EXISTS dim_product_colors;
CREATE TABLE dim_product_colors (
  color_id   BIGSERIAL PRIMARY KEY,
  color_name TEXT       NOT NULL UNIQUE
);
DROP TABLE IF EXISTS dim_product_sizes;
CREATE TABLE dim_product_sizes (
  size_id   BIGSERIAL PRIMARY KEY,
  size_name TEXT       NOT NULL UNIQUE
);
DROP TABLE IF EXISTS dim_product_brands;
CREATE TABLE dim_product_brands (
  brand_id   BIGSERIAL PRIMARY KEY,
  brand_name TEXT       NOT NULL UNIQUE
);
DROP TABLE IF EXISTS dim_product_materials;
CREATE TABLE dim_product_materials (
  material_id   BIGSERIAL PRIMARY KEY,
  material_name TEXT       NOT NULL UNIQUE
);


DROP TABLE IF EXISTS dim_products;
CREATE TABLE dim_products (
  product_id      BIGSERIAL PRIMARY KEY,
  product_name    TEXT       NOT NULL,
  category_id     BIGINT     REFERENCES dim_product_categories(category_id),
  price           NUMERIC(10,2),
  weight          NUMERIC(10,2),
  color_id        BIGINT     REFERENCES dim_product_colors(color_id),
  size_id         BIGINT     REFERENCES dim_product_sizes(size_id),
  brand_id        BIGINT     REFERENCES dim_product_brands(brand_id),
  material_id     BIGINT     REFERENCES dim_product_materials(material_id),
  description     TEXT,
  rating          NUMERIC(3,1),
  reviews         INT,
  release_date_id BIGINT     REFERENCES dim_dates(date_id),
  expiry_date_id  BIGINT     REFERENCES dim_dates(date_id),
  supplier_id     BIGINT     REFERENCES dim_suppliers(supplier_id),
  UNIQUE(product_name, supplier_id)
);

DROP TABLE IF EXISTS dim_customers;
CREATE TABLE dim_customers (
  customer_id  BIGSERIAL PRIMARY KEY,
  first_name   TEXT       NOT NULL,
  last_name    TEXT       NOT NULL,
  age          INT,
  email        TEXT       UNIQUE,
  country_id   BIGINT     REFERENCES dim_countries(country_id),
  postal_code  TEXT,
  pet_id       BIGINT     REFERENCES dim_pets(pet_id)
);

DROP TABLE IF EXISTS dim_sellers;
CREATE TABLE dim_sellers (
  seller_id   BIGSERIAL PRIMARY KEY,
  first_name  TEXT       NOT NULL,
  last_name   TEXT       NOT NULL,
  email       TEXT       UNIQUE,
  country_id  BIGINT     REFERENCES dim_countries(country_id),
  postal_code TEXT
);

DROP TABLE IF EXISTS dim_stores;
CREATE TABLE dim_stores (
  store_id    BIGSERIAL PRIMARY KEY,
  store_name  TEXT       NOT NULL,
  location    TEXT,
  city_id     BIGINT     REFERENCES dim_cities(city_id),
  state       TEXT,
  country_id  BIGINT     REFERENCES dim_countries(country_id),
  phone       TEXT,
  email       TEXT,
  UNIQUE(store_name, location)
);

DROP TABLE IF EXISTS fact_sales;
CREATE TABLE fact_sales (
  sale_id      BIGSERIAL   PRIMARY KEY,
  date_id      BIGINT      NOT NULL REFERENCES dim_dates(date_id),
  customer_id  BIGINT      NOT NULL REFERENCES dim_customers(customer_id),
  seller_id    BIGINT      NOT NULL REFERENCES dim_sellers(seller_id),
  product_id   BIGINT      NOT NULL REFERENCES dim_products(product_id),
  store_id     BIGINT      NOT NULL REFERENCES dim_stores(store_id),
  quantity     INT         NOT NULL,
  total_price  NUMERIC(12,2) NOT NULL
);

COMMIT;
