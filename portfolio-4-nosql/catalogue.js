const catalogue = db.getSiblingDB("marketbridge_catalogue");
const products = catalogue.products;

products.createIndex({ sku: 1 }, { unique: true });

const records = [
  {
    sku: "MB-CHG-001",
    name: "USB-C Wall Charger",
    category: "Accessories",
    attributes: { wattage: 30, connector: "USB-C" }
  },
  {
    sku: "MB-SHT-001",
    name: "Cotton T-Shirt",
    category: "Clothing",
    attributes: { size: "M", fabric: "Cotton" }
  },
  {
    sku: "MB-CBL-001",
    name: "USB-C Cable",
    category: "Accessories",
    attributes: { length_m: 2, connector: "USB-C" }
  }
];

print("Load catalogue products");
printjson(products.bulkWrite(records.map(product => ({
  replaceOne: {
    filter: { sku: product.sku },
    replacement: product,
    upsert: true
  }
}))));

print("View the three MarketBridge products");
printjson(products.find(
  { sku: { $in: records.map(product => product.sku) } },
  { _id: 0 }
).sort({ sku: 1 }).toArray());

print("Find accessories rated at 30 watts or above");
printjson(products.find(
  { category: "Accessories", "attributes.wattage": { $gte: 30 } },
  { _id: 0, sku: 1, name: 1, "attributes.wattage": 1 }
).toArray());

//The script uses each SKU to find and replace an existing document or insert a new one, so you can rerun it without creating duplicates. On a fresh test database, 
//expect three inserted documents and one match for the final query, MB-CHG-001 — USB-C Wall Charger, 30 W. The cable has no wattage field, so it does not match.
