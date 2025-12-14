const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const newBrand = await prisma.brands.create({
    data: {
      name: 'TestBrand',
      description: 'Тестовий бренд',
      website: 'https://testbrand.example.com'
    }
  });
  console.log('Brand created:', newBrand.name);

  const category = await prisma.categories.findFirst();
  const newProduct = await prisma.products.create({
    data: {
      name: 'Test Product',
      price: 99.99,
      stock_quantity: 10,
      is_active: true,
      category_id: category?.id,
      brand_id: newBrand.id
    }
  });
  console.log('Product created:', newProduct.name);

  const customer = await prisma.customers.findFirst();
  if (customer) {
    await prisma.customers.update({
      where: { id: customer.id },
      data: { phone: '+380991234567' }
    });
    console.log('Customer updated:', customer.username);

    const wishlist = await prisma.wishlists.create({
      data: { customer_id: customer.id, name: 'Test Wishlist' }
    });
    console.log('Wishlist created:', wishlist.name);

    await prisma.wishlist_items.create({
      data: { wishlist_id: wishlist.id, product_id: newProduct.id }
    });
    console.log('Wishlist item added');
  }

  const products = await prisma.products.findMany({
    where: { brand_id: { not: null } },
    include: { brands: true },
    take: 5
  });
  console.log('\nProducts with brands:');
  products.forEach(p => console.log(`  - ${p.name} (${p.brands?.name})`));

  const stats = await Promise.all([
    prisma.customers.count(),
    prisma.products.count(),
    prisma.brands.count(),
    prisma.wishlists.count()
  ]);
  console.log('\nStatistics:');
  console.log('  Customers:', stats[0]);
  console.log('  Products:', stats[1]);
  console.log('  Brands:', stats[2]);
  console.log('  Wishlists:', stats[3]);

  await prisma.products.delete({ where: { id: newProduct.id } });
  await prisma.brands.delete({ where: { id: newBrand.id } });
  console.log('\nTest data cleaned up');
}

main()
  .then(() => prisma.$disconnect())
  .catch((e) => {
    console.error(e);
    prisma.$disconnect();
    process.exit(1);
  });
