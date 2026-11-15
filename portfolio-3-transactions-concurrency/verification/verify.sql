SELECT product_id, quantity_on_hand
FROM inventory
WHERE product_id = 101;

SELECT o.order_id, o.customer_id, o.status,
       oi.product_id, oi.quantity, oi.unit_price
FROM sales_order AS o
JOIN order_item AS oi ON oi.order_id = o.order_id
WHERE oi.product_id = 101
ORDER BY o.order_id DESC;
