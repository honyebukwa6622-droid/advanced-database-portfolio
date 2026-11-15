BEGIN ISOLATION LEVEL READ COMMITTED;

WITH reserved AS (
    UPDATE inventory
    SET quantity_on_hand = quantity_on_hand - 1
    WHERE product_id = 101
      AND quantity_on_hand >= 1
    RETURNING product_id
),
new_order AS (
    INSERT INTO sales_order (customer_id, status)
    SELECT 42, 'COMPLETED'
    FROM reserved
    RETURNING order_id
)
INSERT INTO order_item (order_id, product_id, quantity, unit_price)
SELECT o.order_id, p.product_id, 1, p.current_price
FROM new_order AS o
CROSS JOIN reserved AS r
JOIN product AS p ON p.product_id = r.product_id
RETURNING order_id, product_id, quantity, unit_price;
