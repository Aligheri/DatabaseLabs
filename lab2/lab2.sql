DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS shopping_carts CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS user_role CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS roles CASCADE;

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL UNIQUE,
    CONSTRAINT check_role_name_not_empty CHECK (LENGTH(TRIM(name)) > 0)
);

CREATE TABLE customers (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_username_length CHECK (LENGTH(username) >= 3),
    CONSTRAINT check_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT check_password_hash_not_empty CHECK (LENGTH(password_hash) > 0)
);

CREATE TABLE user_role (
    user_id BIGINT NOT NULL,
    role_id INTEGER NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_category_name_not_empty CHECK (LENGTH(TRIM(name)) > 0)
);

CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    category_id BIGINT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    brand VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    CONSTRAINT check_price_positive CHECK (price >= 0),
    CONSTRAINT check_stock_non_negative CHECK (stock_quantity >= 0),
    CONSTRAINT check_product_name_not_empty CHECK (LENGTH(TRIM(name)) > 0)
);

CREATE TABLE addresses (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    street VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    state VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(255) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    CONSTRAINT check_street_not_empty CHECK (LENGTH(TRIM(street)) > 0),
    CONSTRAINT check_city_not_empty CHECK (LENGTH(TRIM(city)) > 0),
    CONSTRAINT check_postal_code_not_empty CHECK (LENGTH(TRIM(postal_code)) > 0)
);

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    shipping_address_id BIGINT,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(id) ON DELETE SET NULL,
    CONSTRAINT check_total_amount_positive CHECK (total_amount >= 0),
    CONSTRAINT check_status_valid CHECK (status IN ('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'))
);

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT,
    quantity INTEGER NOT NULL,
    price_per_unit NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
    CONSTRAINT check_quantity_positive CHECK (quantity > 0),
    CONSTRAINT check_price_per_unit_positive CHECK (price_per_unit >= 0)
);

CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT check_payment_amount_positive CHECK (amount > 0),
    CONSTRAINT check_payment_method_valid CHECK (payment_method IN ('CREDIT_CARD', 'DEBIT_CARD', 'PAYPAL', 'BANK_TRANSFER', 'CASH')),
    CONSTRAINT check_payment_status_valid CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED'))
);

CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT,
    review_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    CONSTRAINT check_rating_range CHECK (rating >= 1 AND rating <= 5)
);

CREATE TABLE shopping_carts (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

CREATE TABLE cart_items (
    id BIGSERIAL PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    FOREIGN KEY (cart_id) REFERENCES shopping_carts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    CONSTRAINT check_cart_quantity_positive CHECK (quantity > 0),
    CONSTRAINT unique_cart_product UNIQUE (cart_id, product_id)
);

INSERT INTO roles (name) VALUES
    ('USER'),
    ('ADMIN'),
    ('MODERATOR'),
    ('GUEST'),
    ('PREMIUM_USER');

INSERT INTO customers (username, password_hash, email, first_name, last_name) VALUES
    ('john_doe', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'john.doe@example.com', 'John', 'Doe'),
    ('jane_smith', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'jane.smith@example.com', 'Jane', 'Smith'),
    ('bob_johnson', '$2a$10$HfzIhGCCaxqyaIdGgjARSuODD.KhZRiGgqdIxG5CYi2M6IWcAo4ai', 'bob.j@example.com', 'Bob', 'Johnson'),
    ('alice_williams', '$2a$10$ASlPJLGLp8TwdjcxnB4zP.aSOOzfLG5cJeJ0AiIxP2kkPGnFr7SqW', 'alice.w@example.com', 'Alice', 'Williams'),
    ('charlie_brown', '$2a$10$BqUJqhFAg3kPz1fG8.QiYuRt2ZTqQ1u3sQQwIp.jTqKYQ1h4DvWHy', 'charlie.b@example.com', 'Charlie', 'Brown');

INSERT INTO user_role (user_id, role_id) VALUES
    (1, 1),
    (2, 1),
    (2, 2),
    (3, 1),
    (4, 5),
    (5, 3);

INSERT INTO categories (name, description) VALUES
    ('Electronics', 'Electronic devices and gadgets'),
    ('Clothing', 'Apparel and fashion items'),
    ('Books', 'Physical and digital books'),
    ('Home & Garden', 'Home improvement and garden supplies'),
    ('Sports & Outdoors', 'Sports equipment and outdoor gear');

INSERT INTO products (category_id, name, description, price, stock_quantity, brand) VALUES
    (1, 'Laptop Pro 15', 'High-performance laptop with 16GB RAM and 512GB SSD', 1299.99, 25, 'TechBrand'),
    (1, 'Wireless Mouse', 'Ergonomic wireless mouse with precision tracking', 29.99, 150, 'PeripheralCo'),
    (1, 'USB-C Hub', '7-in-1 USB-C hub with HDMI and Ethernet', 49.99, 75, 'TechBrand'),
    (2, 'Cotton T-Shirt', 'Comfortable 100% cotton t-shirt', 19.99, 200, 'FashionWear'),
    (2, 'Denim Jeans', 'Classic fit denim jeans', 59.99, 100, 'DenimCo'),
    (3, 'Programming in Python', 'Comprehensive guide to Python programming', 39.99, 50, 'TechBooks'),
    (4, 'Garden Tool Set', '10-piece garden tool set with carrying case', 79.99, 30, 'GardenPro'),
    (5, 'Yoga Mat', 'Non-slip yoga mat with carrying strap', 24.99, 80, 'FitLife');

INSERT INTO addresses (customer_id, street, city, state, postal_code, country, is_default) VALUES
    (1, '123 Main St', 'New York', 'NY', '10001', 'USA', TRUE),
    (1, '456 Oak Ave', 'Brooklyn', 'NY', '11201', 'USA', FALSE),
    (2, '789 Elm St', 'Los Angeles', 'CA', '90001', 'USA', TRUE),
    (3, '321 Pine Rd', 'Chicago', 'IL', '60601', 'USA', TRUE),
    (4, '654 Maple Dr', 'Houston', 'TX', '77001', 'USA', TRUE),
    (5, '987 Cedar Ln', 'Phoenix', 'AZ', '85001', 'USA', TRUE);

INSERT INTO shopping_carts (customer_id) VALUES
    (1),
    (2),
    (3),
    (4),
    (5);

INSERT INTO cart_items (cart_id, product_id, quantity) VALUES
    (1, 1, 1),
    (1, 2, 2),
    (2, 4, 3),
    (3, 6, 1),
    (4, 8, 2),
    (5, 7, 1);

INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_address_id) VALUES
    (1, '2025-10-15 10:30:00', 'DELIVERED', 1359.97, 1),
    (2, '2025-10-20 14:45:00', 'SHIPPED', 59.97, 3),
    (3, '2025-10-25 09:15:00', 'PROCESSING', 39.99, 4),
    (4, '2025-10-28 16:20:00', 'PENDING', 49.98, 5),
    (5, '2025-11-01 11:00:00', 'DELIVERED', 79.99, 6);

INSERT INTO order_items (order_id, product_id, quantity, price_per_unit) VALUES
    (1, 1, 1, 1299.99),
    (1, 2, 2, 29.99),
    (2, 4, 3, 19.99),
    (3, 6, 1, 39.99),
    (4, 8, 2, 24.99),
    (5, 7, 1, 79.99);

INSERT INTO payments (order_id, payment_date, payment_method, status, amount) VALUES
    (1, '2025-10-15 10:32:00', 'CREDIT_CARD', 'COMPLETED', 1359.97),
    (2, '2025-10-20 14:47:00', 'PAYPAL', 'COMPLETED', 59.97),
    (3, '2025-10-25 09:17:00', 'DEBIT_CARD', 'COMPLETED', 39.99),
    (4, '2025-10-28 16:22:00', 'CREDIT_CARD', 'PENDING', 49.98),
    (5, '2025-11-01 11:02:00', 'BANK_TRANSFER', 'COMPLETED', 79.99);

INSERT INTO reviews (product_id, customer_id, rating, comment, review_date) VALUES
    (1, 1, 5, 'Excellent laptop! Very fast and reliable.', '2025-10-20 15:30:00'),
    (2, 1, 4, 'Good mouse, but battery could last longer.', '2025-10-21 10:15:00'),
    (4, 2, 5, 'Perfect fit and great quality fabric!', '2025-10-25 14:00:00'),
    (6, 3, 5, 'Best Python book for beginners!', '2025-10-30 09:45:00'),
    (7, 5, 4, 'Good quality tools, carrying case is a bit flimsy.', '2025-11-05 16:20:00'),
    (8, 4, 5, 'Love this yoga mat! Non-slip surface works perfectly.', '2025-11-02 08:30:00');

SELECT 'roles' AS table_name, COUNT(*) AS row_count FROM roles
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'user_role', COUNT(*) FROM user_role
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL SELECT 'shopping_carts', COUNT(*) FROM shopping_carts
UNION ALL SELECT 'cart_items', COUNT(*) FROM cart_items
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews;
