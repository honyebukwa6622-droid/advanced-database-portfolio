SELECT sku,
       document ->> 'name' AS product_name,
       document #> '{attributes,wattage}' AS wattage
FROM catalogue_document
WHERE document ->> 'category' = 'Accessories'
  AND CASE
        WHEN jsonb_typeof(document #> '{attributes,wattage}') = 'number'
        THEN (document #>> '{attributes,wattage}')::numeric >= 30
        ELSE false
      END
ORDER BY sku;
