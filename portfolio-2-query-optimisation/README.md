# Portfolio 2 - Query Processing and Optimisation

## Objective

MarketBridge is a simulated Nigerian online retail platform. This exercise tested whether a composite PostgreSQL index improves the query that retrieves the 20 most recent orders for customer 42. The query uses `order_id` to break ties when orders have the same timestamp.

## Query and index

```sql
SELECT order_id, ordered_at, status
FROM sales_order
WHERE customer_id = 42
ORDER BY ordered_at DESC, order_id DESC
LIMIT 20;
```

```sql
CREATE INDEX idx_sales_order_customer_recent
ON sales_order (customer_id, ordered_at DESC, order_id DESC);
```

I ran `EXPLAIN (ANALYZE, BUFFERS)` on the same query and dataset before and after creating the index. The first index column supports the customer filter. The remaining columns match the query’s sort order.

## Measured results

| Measure | Before index | After index |
|---|---|---|
| Scan type | Sequential scan on `sales_order` | Index scan using `idx_sales_order_customer_recent` |
| Separate sort step | Yes - top-N heapsort (27 kB) | No |
| Execution time | 1.670 ms | 0.676 ms |
| Planning time | 0.344 ms | 1.682 ms |
| Shared buffer hits during execution | 173 | 17 |
| Shared buffer reads during execution | 0 | 2 |

## Performance analysis

Before indexing, PostgreSQL scanned `sales_order`, removed 19,800 rows that did not match customer 42, and used a top-N sort to find the 20 most recent matching orders. After indexing, PostgreSQL used `customer_id = 42` as an index condition. It retrieved matching orders in the requested order and stopped after 20 rows, removing the separate sort step.

Execution time fell from 1.670 ms to 0.676 ms, a reduction of approximately 59.5% in the captured runs. Total shared buffer hits and reads during execution fell from 173 to 19. Planning time increased from 0.344 ms to 1.682 ms, so the improvement applies to execution time. Adding the reported planning and execution times gives 2.014 ms before indexing and 2.358 ms after indexing.

The indexed plan did less work during execution. These two runs show how the index changed the plan, but repeated measurements would be needed to establish a consistent latency improvement. The index also takes up storage and adds maintenance work when orders are written.

## Evidence

The supporting evidence consists of the exported order-history result, the index creation script, and the before-index and after-index execution plans from Supabase.
