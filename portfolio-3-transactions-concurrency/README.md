# Portfolio 3 - Transactions and Concurrency

## Objective

MarketBridge needs to prevent two customers from buying the last unit of
the same product. I used product 101, the USB-C Wall Charger, to test the
stock deduction and checkout logic in PostgreSQL on Supabase.

## Transaction design

Checkout runs at the `READ COMMITTED` isolation level. A conditional
`UPDATE` deducts one unit only when `quantity_on_hand >= 1`. The checkout
statement creates the order and its order item only if the update reserves
a unit. The order item stores the checkout price.

## Observed results

| Test | Supabase result |
|---|---|
| Starting inventory | Product 101 had 1 unit in stock. |
| Inside the rollback test | The stock deduction reduced the quantity to 0. |
| After rollback | A separate query showed that the quantity returned to 1. |
| Checkout statement for customer 42 | Returned order 20001 for 1 unit of product 101 at ₦12,500.00. |
| Checkout statement for customer 43 | Returned order 20002 for 1 unit of product 101 at ₦12,500.00. |

## Rollback analysis

The rollback test showed that the transaction could see its own stock
deduction. After `ROLLBACK`, a separate query confirmed that the original
quantity of 1 had been restored.

## Concurrency analysis

Both checkout screenshots show a row returned by `INSERT ... RETURNING`.
A returned row records the statement result within its transaction.
The screenshots do not establish whether either order was committed or
whether the second checkout waited on the first transaction's row lock.

To verify concurrent checkout, run the two transactions on separate,
persistent PostgreSQL connections. Start with one unit. Leave the first
transaction open after it reserves the unit, then start the second checkout.
After the first transaction commits, the second should return zero rows
because PostgreSQL rechecks the stock condition. Verify the result from a
separate connection by checking that stock is zero and only one order from
that test was committed.
