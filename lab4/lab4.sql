SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM products) AS total_products,
    (SELECT COUNT(*) FROM reviews) AS total_reviews;

SELECT
    status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS average_order_value,
    MIN(total_amount) AS min_order_value,
    MAX(total_amount) AS max_order_value
FROM orders
GROUP BY status
ORDER BY total_revenue DESC;

SELECT
    c.name AS category_name,
    COUNT(p.id) AS product_count,
    AVG(p.price) AS average_price,
    MIN(p.price) AS min_price,
    MAX(p.price) AS max_price,
    SUM(p.stock_quantity) AS total_stock
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.name
ORDER BY product_count DESC;

SELECT
    c.id,
    c.username,
    c.email,
    COUNT(o.id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.username, c.email
HAVING COUNT(o.id) > 0
ORDER BY total_spent DESC;

SELECT
    p.id,
    p.name AS product_name,
    p.brand,
    p.price,
    COUNT(r.id) AS review_count,
    AVG(r.rating) AS average_rating,
    MIN(r.rating) AS min_rating,
    MAX(r.rating) AS max_rating
FROM products p
INNER JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name, p.brand, p.price
HAVING COUNT(r.id) >= 1
ORDER BY average_rating DESC, review_count DESC;

SELECT
    payment_method,
    COUNT(*) AS payment_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS average_amount
FROM payments
WHERE status = 'COMPLETED'
GROUP BY payment_method
HAVING SUM(amount) > 50
ORDER BY total_amount DESC;

SELECT
    o.id AS order_id,
    o.order_date,
    o.status,
    o.total_amount,
    c.username,
    c.email,
    a.street,
    a.city,
    a.state,
    a.country
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
INNER JOIN addresses a ON o.shipping_address_id = a.id
ORDER BY o.order_date DESC;

SELECT
    c.id,
    c.username,
    c.email,
    c.created_at,
    o.id AS order_id,
    o.order_date,
    o.status,
    o.total_amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
ORDER BY c.username, o.order_date DESC;

SELECT
    p.id AS product_id,
    p.name AS product_name,
    p.price,
    p.stock_quantity,
    p.brand,
    c.id AS category_id,
    c.name AS category_name,
    c.description AS category_description
FROM categories c
RIGHT JOIN products p ON c.id = p.category_id
ORDER BY c.name, p.name;

SELECT
    c.id AS customer_id,
    c.username,
    c.email,
    r.id AS role_id,
    r.name AS role_name
FROM customers c
FULL OUTER JOIN user_role ur ON c.id = ur.user_id
FULL OUTER JOIN roles r ON ur.role_id = r.id
ORDER BY c.username, r.name;

SELECT
    o.id AS order_id,
    o.order_date,
    c.username AS customer_name,
    oi.id AS order_item_id,
    p.name AS product_name,
    p.brand,
    oi.quantity,
    oi.price_per_unit,
    (oi.quantity * oi.price_per_unit) AS line_total
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN products p ON oi.product_id = p.id
ORDER BY o.order_date DESC, o.id, oi.id;

SELECT
    c.name AS category_name,
    os.status AS order_status,
    COUNT(DISTINCT o.id) AS order_count
FROM categories c
CROSS JOIN (
    SELECT DISTINCT status FROM orders
) AS os
LEFT JOIN products p ON c.id = p.category_id
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id AND o.status = os.status
GROUP BY c.name, os.status
ORDER BY c.name, os.status;

SELECT
    c.id,
    c.username,
    c.email,
    (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.id) AS total_orders,
    (SELECT COUNT(*) FROM reviews r WHERE r.customer_id = c.id) AS total_reviews,
    (SELECT COALESCE(SUM(o.total_amount), 0) FROM orders o WHERE o.customer_id = c.id) AS total_spent
FROM customers c
ORDER BY total_spent DESC;

SELECT
    p.id,
    p.name AS product_name,
    p.price,
    p.brand,
    c.name AS category_name
FROM products p
INNER JOIN categories c ON p.category_id = c.id
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM products p2
    WHERE p2.category_id = p.category_id
)
ORDER BY c.name, p.price DESC;

SELECT
    c.id,
    c.username,
    c.email,
    o.id AS order_id,
    o.total_amount,
    o.order_date
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
WHERE o.total_amount > (SELECT AVG(total_amount) FROM orders)
ORDER BY o.total_amount DESC;

SELECT
    c.id,
    c.name AS category_name,
    COUNT(p.id) AS product_count,
    AVG(p.price) AS avg_category_price
FROM categories c
INNER JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.name
HAVING AVG(p.price) > (SELECT AVG(price) FROM products)
ORDER BY avg_category_price DESC;

SELECT
    p.id,
    p.name AS product_name,
    p.price,
    p.brand,
    c.name AS category_name
FROM products p
INNER JOIN categories c ON p.category_id = c.id
WHERE EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.id
)
ORDER BY p.name;

SELECT
    p.id,
    p.name AS product_name,
    p.price,
    p.stock_quantity,
    p.brand,
    c.name AS category_name
FROM products p
INNER JOIN categories c ON p.category_id = c.id
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.id
)
ORDER BY p.price DESC;
