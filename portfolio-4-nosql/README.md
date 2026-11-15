# Portfolio 4 - NoSQL and Advanced Data Models

## Objective

I implemented a document-style product catalogue for MarketBridge using PostgreSQL JSONB in Supabase. The catalogue uses the same three product SKUs as the relational database from Portfolio 1.

## Design

The `catalogue_document` table stores one JSONB document per SKU. The SKU is the primary key and references `product.sku`, so every catalogue document is linked to an existing product. The document contains the product name, category and an `attributes` object. The load script updates the document if the SKU already exists.

This model lets products carry different attributes without adding a column for every possible product detail. Checkout prices, inventory and orders remain in the relational tables.

## Supabase results

The catalogue query returned three rows.

| SKU | Product | Category | Attributes |
|---|---|---|---|
| `MB-CBL-001` | USB-C Cable | Accessories | 2 m length, USB-C connector |
| `MB-CHG-001` | USB-C Wall Charger | Accessories | 30 W, USB-C connector |
| `MB-SHT-001` | Cotton T-Shirt | Clothing | Size M, cotton fabric |

The second query filtered Accessories for a numeric wattage of at least 30 W. It returned one row, `MB-CHG-001`, the USB-C Wall Charger, with a wattage of 30. The cable belongs to the same category but has a length field instead of a wattage field. The query checks the JSON type before converting the value to a number, so documents with missing or non-numeric wattage are excluded.

## What the test showed

The charger and cable can share a category while carrying different technical details. JSONB supports queries over those nested details while the SKU foreign key preserves the link to the relational product table.
