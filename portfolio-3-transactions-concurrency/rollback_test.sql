BEGIN;

UPDATE inventory
SET quantity_on_hand = quantity_on_hand - 1
WHERE product_id = 101
  AND quantity_on_hand >= 1;

SELECT quantity_on_hand AS stock_inside_transaction
FROM inventory
WHERE product_id = 101;

ROLLBACK;
