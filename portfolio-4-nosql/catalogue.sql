CREATE TABLE IF NOT EXISTS catalogue_document (
    sku text PRIMARY KEY REFERENCES product (sku),
    document jsonb NOT NULL,
    CHECK (jsonb_typeof(document) = 'object'),
    CHECK (document ? 'attributes'
           AND jsonb_typeof(document -> 'attributes') = 'object')
);

INSERT INTO catalogue_document (sku, document)
VALUES
    ('MB-CHG-001', '{
        "name": "USB-C Wall Charger",
        "category": "Accessories",
        "attributes": {"wattage": 30, "connector": "USB-C"}
    }'),
    ('MB-SHT-001', '{
        "name": "Cotton T-Shirt",
        "category": "Clothing",
        "attributes": {"size": "M", "fabric": "Cotton"}
    }'),
    ('MB-CBL-001', '{
        "name": "USB-C Cable",
        "category": "Accessories",
        "attributes": {"length_m": 2, "connector": "USB-C"}
    }')
ON CONFLICT (sku) DO UPDATE
SET document = EXCLUDED.document;
