-- CreateTable (базова міграція - імпортована схема з БД)
-- Ця міграція є baseline для існуючої бази даних ecommerce_lab2

-- Таблиця ролей
CREATE TABLE "roles" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(20) NOT NULL,
    CONSTRAINT "roles_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "check_role_name_not_empty" CHECK (LENGTH(TRIM(name)) > 0)
);

-- Таблиця користувачів
CREATE TABLE "customers" (
    "id" BIGSERIAL NOT NULL,
    "username" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "first_name" VARCHAR(255),
    "last_name" VARCHAR(255),
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "customers_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "check_username_length" CHECK (LENGTH(username) >= 3),
    CONSTRAINT "check_email_format" CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT "check_password_hash_not_empty" CHECK (LENGTH(password_hash) > 0)
);

-- Таблиця зв'язку користувачів і ролей
CREATE TABLE "user_role" (
    "user_id" BIGINT NOT NULL,
    "role_id" INTEGER NOT NULL,
    CONSTRAINT "user_role_pkey" PRIMARY KEY ("user_id","role_id")
);

-- Таблиця категорій
CREATE TABLE "categories" (
    "id" BIGSERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "categories_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "check_category_name_not_empty" CHECK (LENGTH(TRIM(name)) > 0)
);

-- Таблиця товарів
CREATE TABLE "products" (
    "id" BIGSERIAL NOT NULL,
    "category_id" BIGINT,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "price" DECIMAL(10,2) NOT NULL,
    "stock_quantity" INTEGER NOT NULL DEFAULT 0,
    "brand" VARCHAR(255),
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "products_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "check_price_positive" CHECK (price >= 0),
    CONSTRAINT "check_stock_non_negative" CHECK (stock_quantity >= 0),
    CONSTRAINT "check_product_name_not_empty" CHECK (LENGTH(TRIM(name)) > 0)
);

-- Таблиця адрес
CREATE TABLE "addresses" (
    "id" BIGSERIAL NOT NULL,
    "customer_id" BIGINT NOT NULL,
    "street" VARCHAR(255) NOT NULL,
    "city" VARCHAR(255) NOT NULL,
    "state" VARCHAR(255) NOT NULL,
    "postal_code" VARCHAR(20) NOT NULL,
    "country" VARCHAR(255) NOT NULL,
    "is_default" BOOLEAN DEFAULT false,
    CONSTRAINT "addresses_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "check_street_not_empty" CHECK (LENGTH(TRIM(street)) > 0),
    CONSTRAINT "check_city_not_empty" CHECK (LENGTH(TRIM(city)) > 0),
    CONSTRAINT "check_postal_code_not_empty" CHECK (LENGTH(TRIM(postal_code)) > 0)
);

-- Таблиця замовлень
CREATE TABLE "orders" (
    "id" BIGSERIAL NOT NULL,
    "customer_id" BIGINT NOT NULL,
    "order_date" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" VARCHAR(50) NOT NULL,
    "total_amount" DECIMAL(10,2) NOT NULL,
    "shipping_address_id" BIGINT,
    CONSTRAINT "orders_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "check_total_amount_positive" CHECK (total_amount >= 0),
    CONSTRAINT "check_status_valid" CHECK (status IN ('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'))
);

-- Таблиця позицій замовлення
CREATE TABLE "order_items" (
    "id" BIGSERIAL NOT NULL,
    "order_id" BIGINT NOT NULL,
    "product_id" BIGINT,
    "quantity" INTEGER NOT NULL,
    "price_per_unit" DECIMAL(10,2) NOT NULL,
    CONSTRAINT "order_items_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "check_quantity_positive" CHECK (quantity > 0),
    CONSTRAINT "check_price_per_unit_positive" CHECK (price_per_unit >= 0)
);

-- Таблиця платежів
CREATE TABLE "payments" (
    "id" BIGSERIAL NOT NULL,
    "order_id" BIGINT NOT NULL,
    "payment_date" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "payment_method" VARCHAR(50) NOT NULL,
    "status" VARCHAR(50) NOT NULL,
    "amount" DECIMAL(10,2) NOT NULL,
    CONSTRAINT "payments_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "check_payment_amount_positive" CHECK (amount > 0),
    CONSTRAINT "check_payment_method_valid" CHECK (payment_method IN ('CREDIT_CARD', 'DEBIT_CARD', 'PAYPAL', 'BANK_TRANSFER', 'CASH')),
    CONSTRAINT "check_payment_status_valid" CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED'))
);

-- Таблиця відгуків
CREATE TABLE "reviews" (
    "id" BIGSERIAL NOT NULL,
    "product_id" BIGINT NOT NULL,
    "customer_id" BIGINT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "review_date" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "reviews_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "check_rating_range" CHECK (rating >= 1 AND rating <= 5)
);

-- Таблиця кошиків
CREATE TABLE "shopping_carts" (
    "id" BIGSERIAL NOT NULL,
    "customer_id" BIGINT NOT NULL,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "shopping_carts_pkey" PRIMARY KEY ("id")
);

-- Таблиця позицій кошика
CREATE TABLE "cart_items" (
    "id" BIGSERIAL NOT NULL,
    "cart_id" BIGINT NOT NULL,
    "product_id" BIGINT NOT NULL,
    "quantity" INTEGER NOT NULL,
    CONSTRAINT "cart_items_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "check_cart_quantity_positive" CHECK (quantity > 0)
);

-- CreateIndex (унікальні індекси)
CREATE UNIQUE INDEX "roles_name_key" ON "roles"("name");
CREATE UNIQUE INDEX "customers_username_key" ON "customers"("username");
CREATE UNIQUE INDEX "customers_email_key" ON "customers"("email");
CREATE UNIQUE INDEX "payments_order_id_key" ON "payments"("order_id");
CREATE UNIQUE INDEX "shopping_carts_customer_id_key" ON "shopping_carts"("customer_id");
CREATE UNIQUE INDEX "cart_items_cart_id_product_id_key" ON "cart_items"("cart_id", "product_id");

-- AddForeignKey (зовнішні ключі)
ALTER TABLE "user_role" ADD CONSTRAINT "user_role_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "user_role" ADD CONSTRAINT "user_role_role_id_fkey"
    FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "products" ADD CONSTRAINT "products_category_id_fkey"
    FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "addresses" ADD CONSTRAINT "addresses_customer_id_fkey"
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "orders" ADD CONSTRAINT "orders_customer_id_fkey"
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "orders" ADD CONSTRAINT "orders_shipping_address_id_fkey"
    FOREIGN KEY ("shipping_address_id") REFERENCES "addresses"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_order_id_fkey"
    FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_product_id_fkey"
    FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "payments" ADD CONSTRAINT "payments_order_id_fkey"
    FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_product_id_fkey"
    FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_customer_id_fkey"
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "shopping_carts" ADD CONSTRAINT "shopping_carts_customer_id_fkey"
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "cart_items" ADD CONSTRAINT "cart_items_cart_id_fkey"
    FOREIGN KEY ("cart_id") REFERENCES "shopping_carts"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "cart_items" ADD CONSTRAINT "cart_items_product_id_fkey"
    FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;
