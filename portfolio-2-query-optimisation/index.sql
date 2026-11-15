CREATE INDEX idx_sales_order_customer_recent
ON sales_order (customer_id, ordered_at DESC, order_id DESC);

ANALYZE sales_order;
