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


## Verification results

Product 101 started with one unit. Inside the rollback test, the stock
dropped to zero. A separate query after `ROLLBACK` showed one unit again,
confirming that the stock deduction was undone.

The checkout statements returned order IDs 20001 and 20002. A subsequent
verification query showed one unit still in stock and no matching order
items for either ID. The available results verify rollback. The commit
and concurrent checkout tests still require separate evidence.

