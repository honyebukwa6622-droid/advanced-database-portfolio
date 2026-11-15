WITH all_data AS (
    SELECT 1 AS table_order, 'customer' AS table_name,
           customer_id::bigint AS row_id, 0 AS line_id, to_jsonb(c) AS record
    FROM customer AS c

    UNION ALL
    SELECT 2, 'product', product_id::bigint, 0, to_jsonb(p)
    FROM product AS p

    UNION ALL
    SELECT 3, 'inventory', product_id::bigint, 0, to_jsonb(i)
    FROM inventory AS i

    UNION ALL
    SELECT 4, 'sales_order', order_id, 0, to_jsonb(o)
    FROM sales_order AS o

    UNION ALL
    SELECT 5, 'order_item', order_id, product_id, to_jsonb(oi)
    FROM order_item AS oi
)
SELECT table_name, record
FROM all_data
ORDER BY table_order, row_id, line_id;
