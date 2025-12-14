# Лабораторна робота №6
Тема: Міграції схем за допомогою Prisma ORM

## Імпорт схеми PostgreSQL

Схему з попередньої ЛР було імпортовано через команду `npx prisma db pull`. У файл schema.prisma було зчитано структуру з бази ecommerce_lab2, що включала таблиці:

- customers, products, categories
- orders, order_items, payments
- reviews, addresses, roles
- shopping_carts, cart_items

## Застосовані зміни

### Міграція: schema_modifications

Команда: `npx prisma migrate dev --name schema_modifications`

**Додано нові моделі:**
- `brands` - таблиця брендів (id, name, description, website)
- `wishlists` - списки бажань користувачів
- `wishlist_items` - елементи списків бажань

**Додано поля:**
- `phone` до customers
- `is_active Boolean @default(true)` до products
- `brand_id` до products (FK на brands)

**Видалено поле:**
- `brand` з products (замінено на зв'язок з brands)

## Тестування

Скрипт test.js демонструє створення бренду, продукту, списку бажань та вибірку даних з include.

## Докази виконання

Скріншоти в папці screenshots/:
- Таблиця brands у Prisma Studio
- Таблиця wishlists у Prisma Studio
- Вивід test.js
- Структура проєкту (tree)

## Висновок

Імпортовано схему БД через prisma db pull, створено міграцію з новими моделями та полями, протестовано зміни через Prisma Client.
