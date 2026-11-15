SELECT
    i.product_id,
    i.quantity_on_hand AS current_stock,
    o.order_id,
    o.customer_id,
    o.status,
    oi.quantity,
    oi.unit_price
FROM inventory AS i
LEFT JOIN order_item AS oi
    ON oi.product_id = i.product_id
   AND oi.order_id IN (20001, 20002)
LEFT JOIN sales_order AS o
    ON o.order_id = oi.order_id
WHERE i.product_id = 101
ORDER BY o.order_id;
