BEGIN;

INSERT INTO customer (customer_id, full_name, email)
SELECT n, 'Test Customer ' || n, 'customer' || n || '@example.test'
FROM generate_series(1, 100) AS s(n);

INSERT INTO product (product_id, sku, name, current_price)
VALUES
    (101, 'MB-CHG-001', 'USB-C Wall Charger', 12500.00),
    (102, 'MB-SHT-001', 'Cotton T-Shirt',      7500.00),
    (103, 'MB-CBL-001', 'USB-C Cable',         3500.00);

INSERT INTO inventory (product_id, quantity_on_hand)
VALUES (101, 1), (102, 100), (103, 150);

INSERT INTO sales_order (order_id, customer_id, ordered_at, status)
SELECT n,
       1 + ((n - 1) % 100),
       TIMESTAMPTZ '2026-09-01 08:00:00+01' + n * INTERVAL '1 minute',
       'COMPLETED'
FROM generate_series(1, 20000) AS s(n);

INSERT INTO order_item (order_id, product_id, quantity, unit_price)
SELECT order_id,
       CASE WHEN order_id % 2 = 0 THEN 102 ELSE 103 END,
       1,
       CASE WHEN order_id % 2 = 0 THEN 7500.00 ELSE 3500.00 END
FROM sales_order;

SELECT setval(pg_get_serial_sequence('customer', 'customer_id'), 100);
SELECT setval(pg_get_serial_sequence('product', 'product_id'), 103);
SELECT setval(pg_get_serial_sequence('sales_order', 'order_id'), 20000);

COMMIT;

ANALYZE sales_order;
