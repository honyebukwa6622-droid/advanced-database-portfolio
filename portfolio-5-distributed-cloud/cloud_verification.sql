SELECT
    current_database() AS database_name,
    current_setting('server_version') AS postgresql_version,
    pg_is_in_recovery() AS connected_to_recovery_server,
    (SELECT COUNT(*) FROM customer) AS customers,
    (SELECT COUNT(*) FROM sales_order) AS sales_orders,
    (SELECT COUNT(*) FROM catalogue_document) AS catalogue_documents;
