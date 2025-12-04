SELECT * FROM customers;

SELECT username, email, first_name, last_name FROM customers;

SELECT id, username, email, first_name, last_name, created_at
FROM customers
WHERE username = 'john_doe';

SELECT p.id, p.name, p.price, p.stock_quantity, c.name AS category_name
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE c.name = 'Electronics';

SELECT id, name, price, brand, stock_quantity
FROM products
WHERE price < 50
ORDER BY price ASC;

SELECT id, customer_id, order_date, status, total_amount
FROM orders
WHERE status = 'DELIVERED'
ORDER BY order_date DESC;

SELECT o.id, c.username, o.order_date, o.total_amount, o.status
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.total_amount > 100
ORDER BY o.total_amount DESC;

SELECT r.id, c.username, p.name AS product_name, r.rating, r.comment, r.review_date
FROM reviews r
JOIN customers c ON r.customer_id = c.id
JOIN products p ON r.product_id = p.id
WHERE r.rating = 5;

SELECT id, street, city, state, postal_code, country, is_default
FROM addresses
WHERE customer_id = 1;

SELECT p.id, o.id AS order_id, c.username, p.payment_method, p.amount, p.payment_date
FROM payments p
JOIN orders o ON p.order_id = o.id
JOIN customers c ON o.customer_id = c.id
WHERE p.status = 'COMPLETED';

SELECT ci.id, p.name AS product_name, p.price, ci.quantity,
       (p.price * ci.quantity) AS total_price
FROM cart_items ci
JOIN shopping_carts sc ON ci.cart_id = sc.id
JOIN customers c ON sc.customer_id = c.id
JOIN products p ON ci.product_id = p.id
WHERE c.username = 'john_doe';

SELECT oi.id, p.name AS product_name, oi.quantity, oi.price_per_unit,
       (oi.quantity * oi.price_per_unit) AS line_total
FROM order_items oi
JOIN products p ON oi.product_id = p.id
WHERE oi.order_id = 1;

INSERT INTO customers (username, password_hash, email, first_name, last_name)
VALUES ('david_miller', '$2a$10$XYZ123abcdefghijklmnopqrstuvwxyz', 'david.m@example.com', 'David', 'Miller');

SELECT * FROM customers WHERE username = 'david_miller';

INSERT INTO user_role (user_id, role_id)
VALUES ((SELECT id FROM customers WHERE username = 'david_miller'), 1);

SELECT c.username, r.name AS role_name
FROM user_role ur
JOIN customers c ON ur.user_id = c.id
JOIN roles r ON ur.role_id = r.id
WHERE c.username = 'david_miller';

INSERT INTO categories (name, description)
VALUES ('Toys & Games', 'Toys, board games, and entertainment products');

SELECT * FROM categories WHERE name = 'Toys & Games';

INSERT INTO products (category_id, name, description, price, stock_quantity, brand)
VALUES (
    (SELECT id FROM categories WHERE name = 'Toys & Games'),
    'Chess Board Set',
    'Premium wooden chess board with pieces',
    89.99,
    45,
    'GameMaster'
);

SELECT * FROM products WHERE name = 'Chess Board Set';

INSERT INTO addresses (customer_id, street, city, state, postal_code, country, is_default)
VALUES (
    (SELECT id FROM customers WHERE username = 'david_miller'),
    '555 Market St',
    'San Francisco',
    'CA',
    '94102',
    'USA',
    TRUE
);

SELECT a.*
FROM addresses a
JOIN customers c ON a.customer_id = c.id
WHERE c.username = 'david_miller';

INSERT INTO shopping_carts (customer_id)
VALUES ((SELECT id FROM customers WHERE username = 'david_miller'));

SELECT sc.id, c.username, sc.created_at
FROM shopping_carts sc
JOIN customers c ON sc.customer_id = c.id
WHERE c.username = 'david_miller';

INSERT INTO cart_items (cart_id, product_id, quantity)
VALUES (
    (SELECT id FROM shopping_carts WHERE customer_id = (SELECT id FROM customers WHERE username = 'david_miller')),
    (SELECT id FROM products WHERE name = 'Chess Board Set'),
    1
);

SELECT p.name, ci.quantity, p.price, (p.price * ci.quantity) AS total
FROM cart_items ci
JOIN shopping_carts sc ON ci.cart_id = sc.id
JOIN customers c ON sc.customer_id = c.id
JOIN products p ON ci.product_id = p.id
WHERE c.username = 'david_miller';

INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_address_id)
VALUES (
    (SELECT id FROM customers WHERE username = 'david_miller'),
    CURRENT_TIMESTAMP,
    'PENDING',
    89.99,
    (SELECT id FROM addresses WHERE customer_id = (SELECT id FROM customers WHERE username = 'david_miller') AND is_default = TRUE)
);

SELECT * FROM orders WHERE customer_id = (SELECT id FROM customers WHERE username = 'david_miller');

INSERT INTO order_items (order_id, product_id, quantity, price_per_unit)
VALUES (
    (SELECT id FROM orders WHERE customer_id = (SELECT id FROM customers WHERE username = 'david_miller') ORDER BY order_date DESC LIMIT 1),
    (SELECT id FROM products WHERE name = 'Chess Board Set'),
    1,
    89.99
);

SELECT oi.id, p.name, oi.quantity, oi.price_per_unit
FROM order_items oi
JOIN products p ON oi.product_id = p.id
WHERE oi.order_id = (SELECT id FROM orders WHERE customer_id = (SELECT id FROM customers WHERE username = 'david_miller') ORDER BY order_date DESC LIMIT 1);

INSERT INTO payments (order_id, payment_date, payment_method, status, amount)
VALUES (
    (SELECT id FROM orders WHERE customer_id = (SELECT id FROM customers WHERE username = 'david_miller') ORDER BY order_date DESC LIMIT 1),
    CURRENT_TIMESTAMP,
    'CREDIT_CARD',
    'COMPLETED',
    89.99
);

SELECT p.*, o.id AS order_id
FROM payments p
JOIN orders o ON p.order_id = o.id
WHERE o.customer_id = (SELECT id FROM customers WHERE username = 'david_miller');

UPDATE customers
SET email = 'david.miller.new@example.com'
WHERE username = 'david_miller';

SELECT username, email FROM customers WHERE username = 'david_miller';

UPDATE products
SET price = 79.99, updated_at = CURRENT_TIMESTAMP
WHERE name = 'Chess Board Set';

SELECT name, price, updated_at FROM products WHERE name = 'Chess Board Set';

UPDATE products
SET stock_quantity = stock_quantity + 20, updated_at = CURRENT_TIMESTAMP
WHERE name = 'Laptop Pro 15';

SELECT name, stock_quantity, updated_at FROM products WHERE name = 'Laptop Pro 15';

UPDATE orders
SET status = 'PROCESSING'
WHERE customer_id = (SELECT id FROM customers WHERE username = 'david_miller')
AND status = 'PENDING';

SELECT id, customer_id, status FROM orders
WHERE customer_id = (SELECT id FROM customers WHERE username = 'david_miller');

UPDATE addresses
SET street = '555 Market Street, Apt 12B', postal_code = '94103'
WHERE customer_id = (SELECT id FROM customers WHERE username = 'david_miller')
AND is_default = TRUE;

SELECT * FROM addresses
WHERE customer_id = (SELECT id FROM customers WHERE username = 'david_miller');

UPDATE cart_items
SET quantity = 2
WHERE cart_id = (SELECT id FROM shopping_carts WHERE customer_id = (SELECT id FROM customers WHERE username = 'john_doe'))
AND product_id = (SELECT id FROM products WHERE name = 'Laptop Pro 15');

SELECT ci.id, p.name, ci.quantity
FROM cart_items ci
JOIN products p ON ci.product_id = p.id
WHERE ci.cart_id = (SELECT id FROM shopping_carts WHERE customer_id = (SELECT id FROM customers WHERE username = 'john_doe'));

UPDATE categories
SET description = 'All kinds of electronic devices, computers, and gadgets',
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'Electronics';

SELECT name, description, updated_at FROM categories WHERE name = 'Electronics';

UPDATE addresses
SET is_default = FALSE
WHERE customer_id = (SELECT id FROM customers WHERE username = 'john_doe');

UPDATE addresses
SET is_default = TRUE
WHERE id = 2 AND customer_id = (SELECT id FROM customers WHERE username = 'john_doe');

SELECT id, street, city, is_default FROM addresses
WHERE customer_id = (SELECT id FROM customers WHERE username = 'john_doe');

UPDATE products
SET brand = 'TechBrand Pro', updated_at = CURRENT_TIMESTAMP
WHERE name = 'USB-C Hub';

SELECT name, brand, updated_at FROM products WHERE name = 'USB-C Hub';

UPDATE payments
SET status = 'REFUNDED'
WHERE order_id = (SELECT id FROM orders WHERE customer_id = (SELECT id FROM customers WHERE username = 'charlie_brown'));

SELECT p.id, p.order_id, p.status, p.amount
FROM payments p
JOIN orders o ON p.order_id = o.id
WHERE o.customer_id = (SELECT id FROM customers WHERE username = 'charlie_brown');

SELECT * FROM cart_items
WHERE cart_id = (SELECT id FROM shopping_carts WHERE customer_id = (SELECT id FROM customers WHERE username = 'charlie_brown'));

DELETE FROM cart_items
WHERE cart_id = (SELECT id FROM shopping_carts WHERE customer_id = (SELECT id FROM customers WHERE username = 'charlie_brown'))
AND product_id = (SELECT id FROM products WHERE name = 'Garden Tool Set');

SELECT * FROM cart_items
WHERE cart_id = (SELECT id FROM shopping_carts WHERE customer_id = (SELECT id FROM customers WHERE username = 'charlie_brown'));

SELECT * FROM reviews WHERE customer_id = (SELECT id FROM customers WHERE username = 'john_doe') AND product_id = (SELECT id FROM products WHERE name = 'Wireless Mouse');

DELETE FROM reviews
WHERE customer_id = (SELECT id FROM customers WHERE username = 'john_doe')
AND product_id = (SELECT id FROM products WHERE name = 'Wireless Mouse');

SELECT * FROM reviews WHERE customer_id = (SELECT id FROM customers WHERE username = 'john_doe');

SELECT * FROM addresses WHERE customer_id = (SELECT id FROM customers WHERE username = 'john_doe') AND is_default = FALSE;

DELETE FROM addresses
WHERE customer_id = (SELECT id FROM customers WHERE username = 'john_doe')
AND is_default = FALSE;

SELECT * FROM addresses WHERE customer_id = (SELECT id FROM customers WHERE username = 'john_doe');

SELECT ur.*, c.username, r.name FROM user_role ur
JOIN customers c ON ur.user_id = c.id
JOIN roles r ON ur.role_id = r.id
WHERE c.username = 'jane_smith' AND r.name = 'MODERATOR';

DELETE FROM user_role
WHERE user_id = (SELECT id FROM customers WHERE username = 'jane_smith')
AND role_id = (SELECT id FROM roles WHERE name = 'ADMIN');

SELECT c.username, r.name AS role_name
FROM user_role ur
JOIN customers c ON ur.user_id = c.id
JOIN roles r ON ur.role_id = r.id
WHERE c.username = 'jane_smith';

INSERT INTO products (category_id, name, description, price, stock_quantity, brand)
VALUES (1, 'Test Product', 'Product to be deleted', 9.99, 0, 'TestBrand');

SELECT * FROM products WHERE name = 'Test Product';

DELETE FROM products
WHERE stock_quantity = 0 AND name = 'Test Product';

SELECT * FROM products WHERE name = 'Test Product';

SELECT status, COUNT(*) AS order_count, SUM(total_amount) AS total_revenue
FROM orders
GROUP BY status
ORDER BY total_revenue DESC;

SELECT name, brand, price, stock_quantity
FROM products
ORDER BY price DESC
LIMIT 5;

SELECT c.username, c.email, COUNT(o.id) AS total_orders,
       COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.username, c.email
ORDER BY total_spent DESC;

SELECT p.name, p.brand, COUNT(r.id) AS review_count,
       COALESCE(AVG(r.rating), 0) AS average_rating
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name, p.brand
HAVING COUNT(r.id) > 0
ORDER BY average_rating DESC;

SELECT c.username, COUNT(ci.id) AS items_in_cart,
       COALESCE(SUM(p.price * ci.quantity), 0) AS cart_total
FROM customers c
JOIN shopping_carts sc ON c.id = sc.customer_id
LEFT JOIN cart_items ci ON sc.id = ci.cart_id
LEFT JOIN products p ON ci.product_id = p.id
GROUP BY c.id, c.username
ORDER BY cart_total DESC;

SELECT p.id, p.name, p.price, p.stock_quantity
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
WHERE oi.id IS NULL;

SELECT payment_method, COUNT(*) AS usage_count, SUM(amount) AS total_amount
FROM payments
GROUP BY payment_method
ORDER BY usage_count DESC;

SELECT o.id AS order_id, c.username, c.email, o.order_date, o.status, o.total_amount,
       a.street, a.city, a.state, a.postal_code, a.country
FROM orders o
JOIN customers c ON o.customer_id = c.id
LEFT JOIN addresses a ON o.shipping_address_id = a.id
ORDER BY o.order_date DESC;

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