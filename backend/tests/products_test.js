const request = require('supertest');
const { app, pool } = require('../../src/app');
const { createTestUser, getAuthToken } = require('../helpers');

describe('Products API', () => {
  let buyerToken;
  let sellerToken;
  let testProductId;

  beforeAll(async () => {
    // Create test users
    const buyer = await createTestUser('buyer', 'buyer@test.com');
    const seller = await createTestUser('seller', 'seller@test.com');
    
    buyerToken = await getAuthToken(buyer.email, 'password123');
    sellerToken = await getAuthToken(seller.email, 'password123');
  });

  afterAll(async () => {
    await pool.end();
  });

  describe('POST /api/products', () => {
    it('should create a new product as seller', async () => {
      const productData = {
        title: 'Test Product',
        description: 'Test product description',
        priceETB: 1500,
        categoryId: 'electronics',
        condition: 'new',
        locationCity: 'Addis Ababa',
        quantity: 5,
        isNegotiable: true,
        deliveryAvailable: true,
        deliveryFeeETB: 100,
      };

      const response = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${sellerToken}`)
        .send(productData)
        .expect(201);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data.title).toBe(productData.title);
      expect(response.body.data.priceETB).toBe(productData.priceETB);
      
      testProductId = response.body.data.id;
    });

    it('should reject product creation by buyer', async () => {
      const response = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${buyerToken}`)
        .send({
          title: 'Buyer Product',
          description: 'Should fail',
          priceETB: 1000,
          categoryId: 'electronics',
        })
        .expect(403);
    });

    it('should validate required fields', async () => {
      const response = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${sellerToken}`)
        .send({})
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error).toContain('Validation');
    });
  });

  describe('GET /api/products', () => {
    it('should list products with pagination', async () => {
      const response = await request(app)
        .get('/api/products?page=1&limit=10')
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('products');
      expect(response.body.data).toHaveProperty('pagination');
      expect(Array.isArray(response.body.data.products)).toBe(true);
    });

    it('should filter products by category', async () => {
      const response = await request(app)
        .get('/api/products?category=electronics')
        .expect(200);

      expect(response.body.success).toBe(true);
    });

    it('should search products by keyword', async () => {
      const response = await request(app)
        .get('/api/products?search=Test')
        .expect(200);

      expect(response.body.success).toBe(true);
    });
  });

  describe('GET /api/products/:id', () => {
    it('should get product details', async () => {
      const response = await request(app)
        .get(`/api/products/${testProductId}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(testProductId);
      expect(response.body.data).toHaveProperty('viewCount');
    });

    it('should increment view count', async () => {
      const firstResponse = await request(app)
        .get(`/api/products/${testProductId}`)
        .expect(200);

      const initialViews = firstResponse.body.data.viewCount;

      await request(app)
        .get(`/api/products/${testProductId}`)
        .expect(200);

      const secondResponse = await request(app)
        .get(`/api/products/${testProductId}`)
        .expect(200);

      expect(secondResponse.body.data.viewCount).toBe(initialViews + 1);
    });

    it('should return 404 for non-existent product', async () => {
      await request(app)
        .get('/api/products/nonexistent-id')
        .expect(404);
    });
  });

  describe('PUT /api/products/:id', () => {
    it('should update product as owner', async () => {
      const updateData = {
        title: 'Updated Product Title',
        priceETB: 1800,
        description: 'Updated description',
      };

      const response = await request(app)
        .put(`/api/products/${testProductId}`)
        .set('Authorization', `Bearer ${sellerToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.title).toBe(updateData.title);
      expect(response.body.data.priceETB).toBe(updateData.priceETB);
    });

    it('should reject update by non-owner', async () => {
      const response = await request(app)
        .put(`/api/products/${testProductId}`)
        .set('Authorization', `Bearer ${buyerToken}`)
        .send({ title: 'Unauthorized Update' })
        .expect(403);
    });
  });

  describe('DELETE /api/products/:id', () => {
    it('should delete product as owner', async () => {
      const response = await request(app)
        .delete(`/api/products/${testProductId}`)
        .set('Authorization', `Bearer ${sellerToken}`)
        .expect(200);

      expect(response.body.success).toBe(true);
    });

    it('should verify product is deleted', async () => {
      await request(app)
        .get(`/api/products/${testProductId}`)
        .expect(404);
    });
  });

  describe('Ethiopian-specific features', () => {
    it('should format price in ETB', async () => {
      const response = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${sellerToken}`)
        .send({
          title: 'ETB Test Product',
          description: 'Testing ETB formatting',
          priceETB: 2500.50,
          categoryId: 'electronics',
          locationCity: 'Addis Ababa',
        })
        .expect(201);

      expect(response.body.data.formattedPrice).toContain('ETB');
      expect(response.body.data.formattedPrice).toContain('2,500.50');
    });

    it('should validate Ethiopian location format', async () => {
      const response = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${sellerToken}`)
        .send({
          title: 'Location Test',
          description: 'Testing location validation',
          priceETB: 1000,
          categoryId: 'electronics',
          locationRegion: 'Addis Ababa',
          locationCity: 'Addis Ababa',
          locationSubcity: 'Bole',
        })
        .expect(201);

      expect(response.body.data.locationCity).toBe('Addis Ababa');
      expect(response.body.data.locationSubcity).toBe('Bole');
    });
  });
});