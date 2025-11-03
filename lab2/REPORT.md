# Lab 2: Converting ER Diagram to PostgreSQL Schema - Report

## Student Information
- **Lab**: Lab 2 - Converting ER Diagram to PostgreSQL Schema
- **Database**: E-commerce System
- **Date**: November 3, 2025

## Overview
This lab converts the ER diagram from Lab 1 into a fully functional PostgreSQL relational schema. The database models an e-commerce system with customers, products, orders, payments, reviews, and shopping carts.

## Database Schema Summary

### Tables Overview
The schema consists of 12 tables representing the core entities and relationships of the e-commerce system:

1. **roles** - User role types
2. **customers** - User/customer accounts
3. **user_role** - Junction table (customers ↔ roles)
4. **categories** - Product categories
5. **products** - Products for sale
6. **addresses** - Customer shipping/billing addresses
7. **orders** - Customer orders
8. **order_items** - Junction table (orders ↔ products)
9. **payments** - Payment information for orders
10. **reviews** - Product reviews by customers
11. **shopping_carts** - Customer shopping carts
12. **cart_items** - Junction table (carts ↔ products)

---

## Detailed Table Descriptions

### 1. roles
**Purpose**: Stores different user role types in the system.

**Columns**:
- `id` (SERIAL, PRIMARY KEY) - Unique role identifier
- `name` (VARCHAR(20), NOT NULL, UNIQUE) - Role name

**Constraints**:
- Primary key ensures unique role IDs
- UNIQUE constraint on name prevents duplicate role names
- CHECK constraint ensures role name is not empty

**Sample Data**: USER, ADMIN, MODERATOR, GUEST, PREMIUM_USER

---

### 2. customers
**Purpose**: Stores user/customer account information.

**Columns**:
- `id` (BIGSERIAL, PRIMARY KEY) - Unique customer identifier
- `username` (VARCHAR(255), NOT NULL, UNIQUE) - Login username
- `password_hash` (VARCHAR(255), NOT NULL) - Hashed password
- `email` (VARCHAR(255), NOT NULL, UNIQUE) - Email address
- `first_name` (VARCHAR(255)) - First name
- `last_name` (VARCHAR(255)) - Last name
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - Account creation date

**Constraints**:
- Primary key on id
- UNIQUE constraints on username and email
- CHECK constraint for minimum username length (>= 3)
- CHECK constraint for valid email format (regex validation)
- CHECK constraint ensuring password hash is not empty

**Relationships**:
- One-to-many with addresses
- One-to-many with orders
- One-to-many with reviews
- One-to-one with shopping_carts
- Many-to-many with roles (through user_role)

---

### 3. user_role
**Purpose**: Junction table implementing many-to-many relationship between customers and roles.

**Columns**:
- `user_id` (BIGINT, NOT NULL, FK → customers.id)
- `role_id` (INTEGER, NOT NULL, FK → roles.id)
- **Composite PRIMARY KEY** (user_id, role_id)

**Constraints**:
- Foreign key to customers with CASCADE delete
- Foreign key to roles with CASCADE delete
- Composite primary key prevents duplicate role assignments

**Relationship**: Allows customers to have multiple roles and roles to be assigned to multiple customers.

---

### 4. categories
**Purpose**: Organizes products into categories.

**Columns**:
- `id` (BIGSERIAL, PRIMARY KEY) - Unique category identifier
- `name` (VARCHAR(255), NOT NULL) - Category name
- `description` (TEXT) - Category description
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - Creation timestamp
- `updated_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - Last update timestamp

**Constraints**:
- Primary key on id
- CHECK constraint ensures category name is not empty

**Relationships**:
- One-to-many with products

**Sample Data**: Electronics, Clothing, Books, Home & Garden, Sports & Outdoors

---

### 5. products
**Purpose**: Stores product information available for purchase.

**Columns**:
- `id` (BIGSERIAL, PRIMARY KEY) - Unique product identifier
- `category_id` (BIGINT, FK → categories.id) - Product category
- `name` (VARCHAR(255), NOT NULL) - Product name
- `description` (TEXT) - Product description
- `price` (NUMERIC(10,2), NOT NULL) - Product price
- `stock_quantity` (INTEGER, NOT NULL, DEFAULT 0) - Available stock
- `brand` (VARCHAR(255)) - Product brand
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - Creation timestamp
- `updated_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - Last update timestamp

**Constraints**:
- Primary key on id
- Foreign key to categories (SET NULL on delete)
- CHECK constraint ensuring price >= 0
- CHECK constraint ensuring stock_quantity >= 0
- CHECK constraint ensuring product name is not empty

**Relationships**:
- Many-to-one with categories
- Many-to-many with orders (through order_items)
- Many-to-many with shopping_carts (through cart_items)
- One-to-many with reviews

---

### 6. addresses
**Purpose**: Stores customer shipping and billing addresses.

**Columns**:
- `id` (BIGSERIAL, PRIMARY KEY) - Unique address identifier
- `customer_id` (BIGINT, NOT NULL, FK → customers.id) - Address owner
- `street` (VARCHAR(255), NOT NULL) - Street address
- `city` (VARCHAR(255), NOT NULL) - City
- `state` (VARCHAR(255), NOT NULL) - State/province
- `postal_code` (VARCHAR(20), NOT NULL) - Postal/ZIP code
- `country` (VARCHAR(255), NOT NULL) - Country
- `is_default` (BOOLEAN, DEFAULT FALSE) - Default address flag

**Constraints**:
- Primary key on id
- Foreign key to customers (CASCADE delete)
- CHECK constraints ensuring street, city, and postal_code are not empty

**Relationships**:
- Many-to-one with customers
- One-to-many with orders (as shipping_address_id)

---

### 7. orders
**Purpose**: Stores customer order information.

**Columns**:
- `id` (BIGSERIAL, PRIMARY KEY) - Unique order identifier
- `customer_id` (BIGINT, NOT NULL, FK → customers.id) - Customer who placed order
- `order_date` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) - Order date
- `status` (VARCHAR(50), NOT NULL) - Order status
- `total_amount` (NUMERIC(10,2), NOT NULL) - Total order amount
- `shipping_address_id` (BIGINT, FK → addresses.id) - Shipping address

**Constraints**:
- Primary key on id
- Foreign key to customers (CASCADE delete)
- Foreign key to addresses (SET NULL on delete)
- CHECK constraint ensuring total_amount >= 0
- CHECK constraint for valid status values: PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED

**Relationships**:
- Many-to-one with customers
- Many-to-one with addresses
- One-to-one with payments
- Many-to-many with products (through order_items)

---

### 8. order_items
**Purpose**: Junction table implementing many-to-many relationship between orders and products.

**Columns**:
- `id` (BIGSERIAL, PRIMARY KEY) - Unique order item identifier
- `order_id` (BIGINT, NOT NULL, FK → orders.id) - Associated order
- `product_id` (BIGINT, FK → products.id) - Ordered product
- `quantity` (INTEGER, NOT NULL) - Quantity ordered
- `price_per_unit` (NUMERIC(10,2), NOT NULL) - Price per unit at time of order

**Constraints**:
- Primary key on id
- Foreign key to orders (CASCADE delete)
- Foreign key to products (SET NULL on delete)
- CHECK constraint ensuring quantity > 0
- CHECK constraint ensuring price_per_unit >= 0

**Relationship**: Links orders with products, storing order line item details.

---

### 9. payments
**Purpose**: Stores payment information for orders (one-to-one relationship).

**Columns**:
- `id` (BIGSERIAL, PRIMARY KEY) - Unique payment identifier
- `order_id` (BIGINT, NOT NULL, UNIQUE, FK → orders.id) - Associated order
- `payment_date` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) - Payment date
- `payment_method` (VARCHAR(50), NOT NULL) - Payment method used
- `status` (VARCHAR(50), NOT NULL) - Payment status
- `amount` (NUMERIC(10,2), NOT NULL) - Payment amount

**Constraints**:
- Primary key on id
- UNIQUE constraint on order_id (enforces one-to-one relationship)
- Foreign key to orders (CASCADE delete)
- CHECK constraint ensuring amount > 0
- CHECK constraint for valid payment methods: CREDIT_CARD, DEBIT_CARD, PAYPAL, BANK_TRANSFER, CASH
- CHECK constraint for valid status values: PENDING, COMPLETED, FAILED, REFUNDED

**Relationships**:
- One-to-one with orders

---

### 10. reviews
**Purpose**: Stores customer reviews for products.

**Columns**:
- `id` (BIGSERIAL, PRIMARY KEY) - Unique review identifier
- `product_id` (BIGINT, NOT NULL, FK → products.id) - Reviewed product
- `customer_id` (BIGINT, NOT NULL, FK → customers.id) - Review author
- `rating` (INTEGER, NOT NULL) - Star rating (1-5)
- `comment` (TEXT) - Review text
- `review_date` (TIMESTAMP, NOT NULL, DEFAULT CURRENT_TIMESTAMP) - Review date

**Constraints**:
- Primary key on id
- Foreign key to products (CASCADE delete)
- Foreign key to customers (CASCADE delete)
- CHECK constraint ensuring rating is between 1 and 5 (inclusive)

**Relationships**:
- Many-to-one with products
- Many-to-one with customers

---

### 11. shopping_carts
**Purpose**: Stores shopping carts for customers (one-to-one relationship).

**Columns**:
- `id` (BIGSERIAL, PRIMARY KEY) - Unique cart identifier
- `customer_id` (BIGINT, NOT NULL, UNIQUE, FK → customers.id) - Cart owner
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - Cart creation date

**Constraints**:
- Primary key on id
- UNIQUE constraint on customer_id (enforces one-to-one relationship)
- Foreign key to customers (CASCADE delete)

**Relationships**:
- One-to-one with customers
- Many-to-many with products (through cart_items)

---

### 12. cart_items
**Purpose**: Junction table implementing many-to-many relationship between shopping carts and products.

**Columns**:
- `id` (BIGSERIAL, PRIMARY KEY) - Unique cart item identifier
- `cart_id` (BIGINT, NOT NULL, FK → shopping_carts.id) - Associated cart
- `product_id` (BIGINT, NOT NULL, FK → products.id) - Product in cart
- `quantity` (INTEGER, NOT NULL) - Quantity of product

**Constraints**:
- Primary key on id
- Foreign key to shopping_carts (CASCADE delete)
- Foreign key to products (CASCADE delete)
- CHECK constraint ensuring quantity > 0
- UNIQUE constraint on (cart_id, product_id) to prevent duplicate products in same cart

**Relationship**: Links shopping carts with products.
