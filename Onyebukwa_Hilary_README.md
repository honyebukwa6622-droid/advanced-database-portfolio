# MarketBridge Advanced Database Systems Portfolio

**MIT 8103 | Advanced Database Systems | Individual Practical Portfolio**

**GitHub repository** [MarketBridge Advanced Database Systems Portfolio](https://github.com/honyebukwa6622-droid/advanced-database-portfolio)


## Case study

MarketBridge is a simulated Nigerian online retail platform. Customers browse products, place orders and check their order history. Store staff maintain product listings and inventory, while fulfilment staff process orders.

The portfolio uses PostgreSQL on Supabase. Relational tables hold customers, products, inventory, orders and order items. A JSONB catalogue stores product-specific attributes. The same case study and product identifiers are used across all five activities.

## Portfolio overview

| Activity | Implementation and evidence |
|---|---|
| **1. Database design and modelling** | Designed the relational schema and ER diagram. Loaded synthetic data and checked the stock of product `101`. |
| **2. Query processing and optimisation** | Ran an order-history query and captured PostgreSQL execution plans before and after adding a composite index. |
| **3. Transactions and concurrency** | Verified that rollback restored stock. Tested the checkout statement at `READ COMMITTED`. Commit persistence and concurrent lock behaviour remain unverified. |
| **4. NoSQL and advanced data models** | Implemented a document-style catalogue using PostgreSQL JSONB. The catalogue query returned three products and the wattage query returned one match. |
| **5. Distributed and cloud databases** | Verified the existing Supabase database and proposed a design for replication, failover, reporting and backup recovery. |

## Portfolio 1 - Database design and modelling

The schema uses five tables:

| Table | Purpose |
|---|---|
| `customer` | Stores customer identity and a unique email address. |
| `product` | Stores the unique SKU, product name and current price. |
| `inventory` | Stores stock by product and prevents negative quantities. |
| `sales_order` | Records the customer, order time and order status. |
| `order_item` | Links each order to its products and records the quantity and checkout price. |

The composite key `(order_id, product_id)` identifies each order line. Customer details and product details are stored separately. An order line retains its checkout price so a later catalogue price change does not alter an older order.

The seed script created a dataset for the later query and transaction exercises. The stock check showed **1 unit** of product `101`, the USB-C Wall Charger. The cloud verification in Portfolio 5 separately confirmed **100 customers** and **20,000 sales orders**.

## Portfolio 2 - Query processing and optimisation

The query retrieves the **20 most recent orders for customer 42**. It sorts by `ordered_at DESC` and uses `order_id DESC` as a tie-breaker. I compared the same query using `EXPLAIN (ANALYZE, BUFFERS)` before and after creating an index on `(customer_id, ordered_at DESC, order_id DESC)`.

| Measure | Before index | After index |
|---|---:|---:|
| Scan type | Sequential scan | Index scan |
| Separate sort | Top-N heapsort, 27 kB | No |
| Execution time | 1.670 ms | 0.676 ms |
| Planning time | 0.344 ms | 1.682 ms |
| Shared buffer hits during execution | 173 | 17 |
| Shared buffer reads during execution | 0 | 2 |

Before indexing, PostgreSQL filtered out **19,800 rows** and sorted the matching orders. After indexing, it used the customer ID as an index condition and retrieved rows in the requested order without a separate sort.

Execution time fell by approximately **59.5%** in the captured runs. Planning time increased, and the sum of reported planning and execution times was **2.014 ms before** and **2.358 ms after**. The indexed plan reduced execution work in this test. Repeated measurements would help determine whether it consistently improves overall latency.

## Portfolio 3 - Transactions and concurrency

The checkout statement checks and deducts stock in a single conditional `UPDATE`. It creates the order and order item only when the stock update reserves a unit. The checkout uses `READ COMMITTED` isolation.

| Test | Observed result |
|---|---|
| Starting stock for product `101` | 1 unit |
| Stock inside the rollback test | 0 units |
| Stock after `ROLLBACK` | 1 unit |
| Checkout statement for customer `42` | Returned order `20001` for one charger at ₦12,500.00 |
| Checkout statement for customer `43` | Returned order `20002` for one charger at ₦12,500.00 |
| Subsequent verification | Stock was 1 unit, with no matching order items visible for either returned order ID |

The rollback test showed that the deduction was visible inside its transaction and was undone by `ROLLBACK`. The checkout statements returned rows, but the subsequent query provided no evidence that either checkout persisted.

A concurrency test requires two persistent connections. The first transaction reserves the last unit and holds the inventory row lock. The second attempts checkout while that lock is held. After the first commits, the expected result is zero rows from the second checkout because the stock condition no longer holds. Waiting on the lock and the second checkout’s zero-row result were not captured in the available tests.

## Portfolio 4 - NoSQL and advanced data models

I used PostgreSQL JSONB to model catalogue documents in Supabase. Each product has a SKU, name and category, while the `attributes` object varies by product. The SKU is both the catalogue primary key and a foreign key to the relational product table.

| SKU | Product | Document attributes |
|---|---|---|
| `MB-CBL-001` | USB-C Cable | Length 2 m and USB-C connector |
| `MB-CHG-001` | USB-C Wall Charger | Wattage 30 W and USB-C connector |
| `MB-SHT-001` | Cotton T-Shirt | Size M and cotton fabric |

The catalogue query returned **three documents**. The query for Accessories rated at **30 W or above** returned only the USB-C Wall Charger. The cable was excluded because its document contains a length field and no wattage field. The JSONB structure supports these differing attributes without adding a relational column for every product detail.

## Portfolio 5 - Distributed and cloud databases

The Supabase verification query returned the following.

| Check | Observed result |
|---|---|
| Database | `postgres` |
| PostgreSQL version | `17.11` |
| `pg_is_in_recovery()` | `false` |
| Customers | 100 |
| Sales orders | 20,000 |
| JSONB catalogue documents | 3 |

This verified access to the hosted database and showed that the connected server was outside recovery mode. Replication, backup restoration and failover were considered as design proposals.

In the proposed design, one primary handles checkout writes and immediate order-confirmation reads. A standby in a separate availability zone provides a failover path. An asynchronous reporting replica handles reads that can tolerate a delay, with replication lag monitored against the reporting freshness target. Backups and recovery logs are kept separately so the team can recover from errors that replication itself might propagate.

MarketBridge would start with one writer because checkout updates orders and inventory together. Sharding would add coordination to that transaction and would be reconsidered if measured write load or storage growth justified it.

## Reproducing the work

Run the schema and seed scripts in a fresh PostgreSQL test database. Capture the Portfolio 2 baseline plan before creating its index. Run the rollback exercise before consuming the last unit of product `101`. Load the JSONB catalogue after the relational products exist, then run its listing and wattage queries. The cloud verification query can be run after the catalogue is loaded.

The activity folders contain the supporting SQL, query results, screenshots and design notes. The database credentials needed to connect to Supabase are kept outside the repository.

## Technical reflection

The indexing exercise showed why execution and planning time should be reported separately. The composite index removed a sort and reduced buffer work, but one run per configuration was insufficient to establish a consistent overall latency improvement. The checkout exercise showed why a row returned by `INSERT ... RETURNING` must be followed by a separate verification query when the goal is to demonstrate persistence. The catalogue exercise showed how JSONB accommodates product-specific attributes while keeping a relational key to the underlying product.

## References and AI use

- Miva Open University. *MIT 8103 Advanced Database Systems Continuous Assessment Brief, September Cohort 2026*.
- ChatGPT assisted with structuring the documentation. The observed results reported here are based on queries run in Supabase and their captured outputs. Proposed designs and expected test outcomes are labelled separately.
