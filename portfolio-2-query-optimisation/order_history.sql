SELECT order_id, ordered_at, status
FROM sales_order
WHERE customer_id = 42
ORDER BY ordered_at DESC, order_id DESC
LIMIT 20;
