const { Pool } = require('pg');
const { logger } = require('../utils/logger');

class Database {
  constructor() {
    this.pool = null;
    this.isConnected = false;
  }

  async connect() {
    try {
      this.pool = new Pool({
        host: process.env.DB_HOST || 'localhost',
        port: parseInt(process.env.DB_PORT) || 5432,
        database: process.env.DB_NAME || 'ethio_shop',
        user: process.env.DB_USER || 'ethio_user',
        password: process.env.DB_PASSWORD || 'ethio_password_2024',
        ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
        max: parseInt(process.env.DB_POOL_MAX) || 20,
        min: parseInt(process.env.DB_POOL_MIN) || 5,
        idleTimeoutMillis: parseInt(process.env.DB_POOL_IDLE) || 10000,
        connectionTimeoutMillis: parseInt(process.env.DB_POOL_ACQUIRE) || 30000,
        application_name: 'ethio-shop-api',
      });

      // Test connection
      const client = await this.pool.connect();
      const result = await client.query('SELECT NOW()');
      client.release();
      
      this.isConnected = true;
      logger.info(`✅ Connected to PostgreSQL database: ${process.env.DB_NAME}`);
      logger.debug(`Database time: ${result.rows[0].now}`);
      
      // Handle connection errors
      this.pool.on('error', (err) => {
        logger.error('❌ PostgreSQL pool error:', err);
        this.isConnected = false;
      });

      return this.pool;
    } catch (error) {
      logger.error('❌ Failed to connect to PostgreSQL:', error);
      throw error;
    }
  }

  async query(text, params) {
    if (!this.isConnected) {
      throw new Error('Database not connected');
    }

    const start = Date.now();
    try {
      const result = await this.pool.query(text, params);
      const duration = Date.now() - start;
      
      if (process.env.NODE_ENV === 'development') {
        logger.debug('📝 Executed query:', {
          text,
          params,
          duration: `${duration}ms`,
          rows: result.rowCount,
        });
      }
      
      return result;
    } catch (error) {
      logger.error('❌ Database query error:', {
        text,
        params,
        error: error.message,
      });
      throw error;
    }
  }

  async transaction(callback) {
    const client = await this.pool.connect();
    
    try {
      await client.query('BEGIN');
      const result = await callback(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async close() {
    if (this.pool) {
      await this.pool.end();
      this.isConnected = false;
      logger.info('✅ PostgreSQL connection closed');
    }
  }

  async healthCheck() {
    try {
      const result = await this.query('SELECT 1 as health');
      return {
        status: 'healthy',
        database: process.env.DB_NAME,
        latency: 'OK',
        details: 'PostgreSQL connection is healthy'
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        database: process.env.DB_NAME,
        error: error.message,
        details: 'PostgreSQL connection failed'
      };
    }
  }

  // Helper methods for common operations
  async findOne(table, conditions) {
    const whereClause = Object.keys(conditions)
      .map((key, index) => `${key} = $${index + 1}`)
      .join(' AND ');
    
    const values = Object.values(conditions);
    const query = `SELECT * FROM ${table} WHERE ${whereClause} LIMIT 1`;
    
    const result = await this.query(query, values);
    return result.rows[0] || null;
  }

  async insert(table, data, returning = ['*']) {
    const columns = Object.keys(data).join(', ');
    const placeholders = Object.keys(data)
      .map((_, index) => `$${index + 1}`)
      .join(', ');
    
    const values = Object.values(data);
    const query = `
      INSERT INTO ${table} (${columns})
      VALUES (${placeholders})
      RETURNING ${returning.join(', ')}
    `;
    
    const result = await this.query(query, values);
    return result.rows[0];
  }

  async update(table, conditions, data, returning = ['*']) {
    const setClause = Object.keys(data)
      .map((key, index) => `${key} = $${index + 1}`)
      .join(', ');
    
    const whereClause = Object.keys(conditions)
      .map((key, index) => `${key} = $${index + Object.keys(data).length + 1}`)
      .join(' AND ');
    
    const values = [...Object.values(data), ...Object.values(conditions)];
    const query = `
      UPDATE ${table}
      SET ${setClause}
      WHERE ${whereClause}
      RETURNING ${returning.join(', ')}
    `;
    
    const result = await this.query(query, values);
    return result.rows[0];
  }

  async delete(table, conditions, returning = ['*']) {
    const whereClause = Object.keys(conditions)
      .map((key, index) => `${key} = $${index + 1}`)
      .join(' AND ');
    
    const values = Object.values(conditions);
    const query = `
      DELETE FROM ${table}
      WHERE ${whereClause}
      RETURNING ${returning.join(', ')}
    `;
    
    const result = await this.query(query, values);
    return result.rows[0];
  }
}

// Singleton instance
const database = new Database();

// Export helper functions
const connectDatabase = async () => {
  return await database.connect();
};

const query = async (text, params) => {
  return await database.query(text, params);
};

const transaction = async (callback) => {
  return await database.transaction(callback);
};

const healthCheck = async () => {
  return await database.healthCheck();
};

const closeDatabase = async () => {
  return await database.close();
};

module.exports = {
  pool: database.pool,
  connectDatabase,
  query,
  transaction,
  healthCheck,
  closeDatabase,
  // Export database instance for advanced usage
  db: database,
};