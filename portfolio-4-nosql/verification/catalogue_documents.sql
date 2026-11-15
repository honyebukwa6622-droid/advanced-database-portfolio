SELECT sku,
       document ->> 'name' AS product_name,
       document ->> 'category' AS category,
       document -> 'attributes' AS attributes
FROM catalogue_document
ORDER BY sku;
