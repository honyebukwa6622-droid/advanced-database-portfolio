# Portfolio 3 - Transactions and Concurrency

MarketBridge must prevent two customers from buying the last unit of the
same product. The checkout uses a conditional UPDATE to check and deduct
stock in one statement. The order and order item are created only when that
update reserves a unit.

The concurrency test uses two PostgreSQL connections at READ COMMITTED.
The second checkout waits while the first transaction holds the inventory
row lock. After the first transaction commits, PostgreSQL rechecks the stock
condition. With no stock left, the second checkout creates no order.

The rollback test checks that an uncommitted stock deduction is undone.
The commit test checks that a successful checkout leaves both the order
and its stock deduction in the database.
