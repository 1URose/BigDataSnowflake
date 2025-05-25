BEGIN;


INSERT INTO dim_countries(country_name)
SELECT DISTINCT cn
FROM (
  SELECT customer_country AS cn FROM mock_data WHERE customer_country IS NOT NULL
  UNION
  SELECT seller_country    FROM mock_data WHERE seller_country    IS NOT NULL
  UNION
  SELECT store_country     FROM mock_data WHERE store_country     IS NOT NULL
  UNION
  SELECT supplier_country  FROM mock_data WHERE supplier_country  IS NOT NULL
) AS u
ON CONFLICT(country_name) DO NOTHING;

INSERT INTO dim_cities(city_name)
SELECT DISTINCT city
FROM (
  SELECT store_city    AS city FROM mock_data WHERE store_city    IS NOT NULL
  UNION
  SELECT supplier_city AS city FROM mock_data WHERE supplier_city IS NOT NULL
) AS u
ON CONFLICT(city_name) DO NOTHING;


INSERT INTO dim_dates(full_date, year, quarter, month, day, weekday)
SELECT DISTINCT
  d AS full_date,
  EXTRACT(YEAR    FROM d)::INT    AS year,
  EXTRACT(QUARTER FROM d)::INT    AS quarter,
  EXTRACT(MONTH   FROM d)::INT    AS month,
  EXTRACT(DAY     FROM d)::INT    AS day,
  TO_CHAR(d, 'FMDay')             AS weekday
FROM (
  SELECT TO_DATE(sale_date, 'MM/DD/YYYY')            AS d FROM mock_data WHERE sale_date             IS NOT NULL
  UNION
  SELECT TO_DATE(product_release_date, 'MM/DD/YYYY') AS d FROM mock_data WHERE product_release_date IS NOT NULL
  UNION
  SELECT TO_DATE(product_expiry_date, 'MM/DD/YYYY')  AS d FROM mock_data WHERE product_expiry_date  IS NOT NULL
) AS dates
ON CONFLICT(full_date) DO NOTHING;


INSERT INTO dim_pet_types(pet_type_name)
SELECT DISTINCT customer_pet_type
FROM mock_data
WHERE customer_pet_type IS NOT NULL
ON CONFLICT(pet_type_name) DO NOTHING;

INSERT INTO dim_pet_breeds(pet_breed_name)
SELECT DISTINCT customer_pet_breed
FROM mock_data
WHERE customer_pet_breed IS NOT NULL
ON CONFLICT(pet_breed_name) DO NOTHING;

INSERT INTO dim_pet_categories(pet_category_name)
SELECT DISTINCT pet_category
FROM mock_data
WHERE pet_category IS NOT NULL
ON CONFLICT(pet_category_name) DO NOTHING;


INSERT INTO dim_pets(pet_name, pet_type_id, pet_breed_id, pet_category_id)
SELECT DISTINCT
  md.customer_pet_name,
  pt.pet_type_id,
  pb.pet_breed_id,
  pc.pet_category_id
FROM mock_data md
JOIN dim_pet_types        pt ON md.customer_pet_type = pt.pet_type_name
LEFT JOIN dim_pet_breeds       pb ON md.customer_pet_breed = pb.pet_breed_name
LEFT JOIN dim_pet_categories   pc ON md.pet_category      = pc.pet_category_name
WHERE md.customer_pet_name IS NOT NULL
ON CONFLICT(pet_name, pet_type_id) DO NOTHING;


INSERT INTO dim_suppliers(
  supplier_name, contact_person, supplier_email,
  supplier_phone, supplier_address, city_id, country_id
)
SELECT DISTINCT
  md.supplier_name,
  md.supplier_contact,
  md.supplier_email,
  md.supplier_phone,
  md.supplier_address,
  c.city_id,
  cn.country_id
FROM mock_data md
LEFT JOIN dim_cities    c  ON md.supplier_city    = c.city_name
LEFT JOIN dim_countries cn ON md.supplier_country = cn.country_name
WHERE md.supplier_name IS NOT NULL
ON CONFLICT(supplier_email) DO NOTHING;


INSERT INTO dim_product_categories(category_name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category IS NOT NULL
ON CONFLICT(category_name) DO NOTHING;

INSERT INTO dim_product_colors(color_name)
SELECT DISTINCT product_color
FROM mock_data
WHERE product_color IS NOT NULL
ON CONFLICT(color_name) DO NOTHING;

INSERT INTO dim_product_sizes(size_name)
SELECT DISTINCT product_size
FROM mock_data
WHERE product_size IS NOT NULL
ON CONFLICT(size_name) DO NOTHING;

INSERT INTO dim_product_brands(brand_name)
SELECT DISTINCT product_brand
FROM mock_data
WHERE product_brand IS NOT NULL
ON CONFLICT(brand_name) DO NOTHING;

INSERT INTO dim_product_materials(material_name)
SELECT DISTINCT product_material
FROM mock_data
WHERE product_material IS NOT NULL
ON CONFLICT(material_name) DO NOTHING;


INSERT INTO dim_products(
  product_name, category_id, price, weight,
  color_id, size_id, brand_id, material_id,
  description, rating, reviews,
  release_date_id, expiry_date_id, supplier_id
)
SELECT DISTINCT
  md.product_name,
  pc.category_id,
  md.product_price,
  md.product_weight,
  clr.color_id,
  sz.size_id,
  br.brand_id,
  pm.material_id,
  md.product_description,
  md.product_rating,
  md.product_reviews,
  rd.date_id,
  ed.date_id,
  sp.supplier_id
FROM mock_data md
LEFT JOIN dim_product_categories pc ON md.product_category = pc.category_name
LEFT JOIN dim_product_colors     clr ON md.product_color    = clr.color_name
LEFT JOIN dim_product_sizes      sz  ON md.product_size     = sz.size_name
LEFT JOIN dim_product_brands     br  ON md.product_brand    = br.brand_name
LEFT JOIN dim_product_materials  pm  ON md.product_material = pm.material_name
LEFT JOIN dim_dates              rd  ON TO_DATE(md.product_release_date, 'MM/DD/YYYY') = rd.full_date
LEFT JOIN dim_dates              ed  ON TO_DATE(md.product_expiry_date,  'MM/DD/YYYY') = ed.full_date
LEFT JOIN dim_suppliers          sp  ON md.supplier_email  = sp.supplier_email
WHERE md.product_name IS NOT NULL
ON CONFLICT(product_name, supplier_id) DO NOTHING;


INSERT INTO dim_customers(
  first_name, last_name, age, email, country_id, postal_code, pet_id
)
SELECT DISTINCT
  md.customer_first_name,
  md.customer_last_name,
  md.customer_age,
  md.customer_email,
  cn.country_id,
  md.customer_postal_code,
  p.pet_id
FROM mock_data md
LEFT JOIN dim_countries cn ON md.customer_country = cn.country_name
LEFT JOIN dim_pets      p  ON md.customer_pet_name = p.pet_name
WHERE md.customer_email IS NOT NULL
ON CONFLICT(email) DO NOTHING;


INSERT INTO dim_sellers(
  first_name, last_name, email, country_id, postal_code
)
SELECT DISTINCT
  md.seller_first_name,
  md.seller_last_name,
  md.seller_email,
  cn.country_id,
  md.seller_postal_code
FROM mock_data md
LEFT JOIN dim_countries cn ON md.seller_country = cn.country_name
WHERE md.seller_email IS NOT NULL
ON CONFLICT(email) DO NOTHING;


INSERT INTO dim_stores(
  store_name, location, city_id, state, country_id, phone, email
)
SELECT DISTINCT
  md.store_name,
  md.store_location,
  c.city_id,
  md.store_state,
  cn.country_id,
  md.store_phone,
  md.store_email
FROM mock_data md
LEFT JOIN dim_cities    c  ON md.store_city    = c.city_name
LEFT JOIN dim_countries cn ON md.store_country = cn.country_name
WHERE md.store_name IS NOT NULL
ON CONFLICT(store_name, location) DO NOTHING;


INSERT INTO fact_sales(
  date_id, customer_id, seller_id,
  product_id, store_id, quantity, total_price
)
SELECT
  d.date_id,
  cu.customer_id,
  se.seller_id,
  pr.product_id,
  st.store_id,
  md.sale_quantity,
  md.sale_total_price
FROM mock_data md
JOIN dim_dates     d  ON TO_DATE(md.sale_date, 'MM/DD/YYYY') = d.full_date
JOIN dim_customers cu ON md.customer_email = cu.email
JOIN dim_sellers   se ON md.seller_email   = se.email
JOIN dim_products  pr ON md.product_name   = pr.product_name
JOIN dim_stores    st ON md.store_name     = st.store_name
WHERE md.sale_quantity IS NOT NULL
ON CONFLICT DO NOTHING;

COMMIT;
