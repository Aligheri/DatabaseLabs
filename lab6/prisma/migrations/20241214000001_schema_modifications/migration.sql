ALTER TABLE "customers" ADD COLUMN "phone" VARCHAR(20);

CREATE TABLE "brands" (
    "id" BIGSERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "website" VARCHAR(255),
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "brands_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "brands_name_key" ON "brands"("name");

INSERT INTO "brands" ("name")
SELECT DISTINCT "brand" FROM "products"
WHERE "brand" IS NOT NULL AND "brand" != '';

ALTER TABLE "products" ADD COLUMN "brand_id" BIGINT;

UPDATE "products" p
SET "brand_id" = b."id"
FROM "brands" b
WHERE p."brand" = b."name";

ALTER TABLE "products" ADD CONSTRAINT "products_brand_id_fkey"
    FOREIGN KEY ("brand_id") REFERENCES "brands"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "products" DROP COLUMN "brand";

ALTER TABLE "products" ADD COLUMN "is_active" BOOLEAN NOT NULL DEFAULT true;

CREATE TABLE "wishlists" (
    "id" BIGSERIAL NOT NULL,
    "customer_id" BIGINT NOT NULL,
    "name" VARCHAR(100) NOT NULL DEFAULT 'My Wishlist',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "wishlists_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "wishlists" ADD CONSTRAINT "wishlists_customer_id_fkey"
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

CREATE TABLE "wishlist_items" (
    "id" BIGSERIAL NOT NULL,
    "wishlist_id" BIGINT NOT NULL,
    "product_id" BIGINT NOT NULL,
    "added_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "wishlist_items_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "wishlist_items_wishlist_id_product_id_key"
    ON "wishlist_items"("wishlist_id", "product_id");

ALTER TABLE "wishlist_items" ADD CONSTRAINT "wishlist_items_wishlist_id_fkey"
    FOREIGN KEY ("wishlist_id") REFERENCES "wishlists"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "wishlist_items" ADD CONSTRAINT "wishlist_items_product_id_fkey"
    FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;

INSERT INTO "wishlists" ("customer_id", "name") VALUES
    (1, 'Johns Wishlist'),
    (2, 'Janes Tech Wishlist'),
    (3, 'Bobs Books'),
    (4, 'Alices Favorites');

INSERT INTO "wishlist_items" ("wishlist_id", "product_id") VALUES
    (1, 3),
    (1, 5),
    (2, 1),
    (2, 2),
    (3, 6),
    (4, 7),
    (4, 8);
