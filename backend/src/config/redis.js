const redis = require('redis');
const { logger } = require('../utils/logger');

class RedisClient {
  constructor() {
    this.client = null;
    this.isConnected = false;
    this.subscriber = null;
    this.publisher = null;
  }

  async connect() {
    try {
      const redisConfig = {
        socket: {
          host: process.env.REDIS_HOST || 'localhost',
          port: parseInt(process.env.REDIS_PORT) || 6379,
          reconnectStrategy: (retries) => {
            if (retries > 10) {
              logger.error('❌ Redis reconnection attempts exceeded');
              return new Error('Redis reconnection failed');
            }
            return Math.min(retries * 100, 3000);
          }
        },
        password: process.env.REDIS_PASSWORD || undefined,
        database: parseInt(process.env.REDIS_DB) || 0,
      };

      this.client = redis.createClient(redisConfig);
      
      // Create separate clients for pub/sub if needed
      this.subscriber = this.client.duplicate();
      this.publisher = this.client.duplicate();

      // Event listeners
      this.client.on('connect', () => {
        logger.info('🔴 Redis client connecting...');
      });

      this.client.on('ready', () => {
        this.isConnected = true;
        logger.info('✅ Redis client connected and ready');
      });

      this.client.on('error', (error) => {
        logger.error('❌ Redis client error:', error);
        this.isConnected = false;
      });

      this.client.on('end', () => {
        logger.warn('⚠️ Redis client connection ended');
        this.isConnected = false;
      });

      this.client.on('reconnecting', () => {
        logger.info('🔄 Redis client reconnecting...');
      });

      // Connect all clients
      await Promise.all([
        this.client.connect(),
        this.subscriber.connect(),
        this.publisher.connect()
      ]);

      return this.client;
    } catch (error) {
      logger.error('❌ Failed to connect to Redis:', error);
      throw error;
    }
  }

  async set(key, value, ttl = null) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      if (ttl) {
        await this.client.setEx(key, ttl, JSON.stringify(value));
      } else {
        await this.client.set(key, JSON.stringify(value));
      }
      
      logger.debug(`📝 Redis SET: ${key}`);
      return true;
    } catch (error) {
      logger.error('❌ Redis SET error:', error);
      throw error;
    }
  }

  async get(key) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      const value = await this.client.get(key);
      logger.debug(`📝 Redis GET: ${key}`);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.error('❌ Redis GET error:', error);
      throw error;
    }
  }

  async del(key) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      const result = await this.client.del(key);
      logger.debug(`📝 Redis DEL: ${key}`);
      return result;
    } catch (error) {
      logger.error('❌ Redis DEL error:', error);
      throw error;
    }
  }

  async exists(key) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      const result = await this.client.exists(key);
      return result === 1;
    } catch (error) {
      logger.error('❌ Redis EXISTS error:', error);
      throw error;
    }
  }

  async expire(key, ttl) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      await this.client.expire(key, ttl);
      logger.debug(`📝 Redis EXPIRE: ${key} -> ${ttl}s`);
      return true;
    } catch (error) {
      logger.error('❌ Redis EXPIRE error:', error);
      throw error;
    }
  }

  async ttl(key) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      const result = await this.client.ttl(key);
      return result;
    } catch (error) {
      logger.error('❌ Redis TTL error:', error);
      throw error;
    }
  }

  async incr(key) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      const result = await this.client.incr(key);
      return result;
    } catch (error) {
      logger.error('❌ Redis INCR error:', error);
      throw error;
    }
  }

  async decr(key) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      const result = await this.client.decr(key);
      return result;
    } catch (error) {
      logger.error('❌ Redis DECR error:', error);
      throw error;
    }
  }

  async hset(key, field, value) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      await this.client.hSet(key, field, JSON.stringify(value));
      logger.debug(`📝 Redis HSET: ${key}.${field}`);
      return true;
    } catch (error) {
      logger.error('❌ Redis HSET error:', error);
      throw error;
    }
  }

  async hget(key, field) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      const value = await this.client.hGet(key, field);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      logger.error('❌ Redis HGET error:', error);
      throw error;
    }
  }

  async hgetall(key) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      const data = await this.client.hGetAll(key);
      const result = {};
      
      for (const [field, value] of Object.entries(data)) {
        result[field] = JSON.parse(value);
      }
      
      return result;
    } catch (error) {
      logger.error('❌ Redis HGETALL error:', error);
      throw error;
    }
  }

  async publish(channel, message) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      await this.publisher.publish(channel, JSON.stringify(message));
      logger.debug(`📡 Redis PUBLISH: ${channel}`);
      return true;
    } catch (error) {
      logger.error('❌ Redis PUBLISH error:', error);
      throw error;
    }
  }

  async subscribe(channel, callback) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      await this.subscriber.subscribe(channel, (message) => {
        try {
          callback(JSON.parse(message));
        } catch (error) {
          logger.error('❌ Error parsing Redis message:', error);
        }
      });
      
      logger.debug(`📡 Redis SUBSCRIBE: ${channel}`);
      return true;
    } catch (error) {
      logger.error('❌ Redis SUBSCRIBE error:', error);
      throw error;
    }
  }

  async unsubscribe(channel) {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      await this.subscriber.unsubscribe(channel);
      logger.debug(`📡 Redis UNSUBSCRIBE: ${channel}`);
      return true;
    } catch (error) {
      logger.error('❌ Redis UNSUBSCRIBE error:', error);
      throw error;
    }
  }

  async flushAll() {
    if (!this.isConnected) {
      throw new Error('Redis not connected');
    }

    try {
      await this.client.flushAll();
      logger.warn('⚠️ Redis FLUSHALL executed');
      return true;
    } catch (error) {
      logger.error('❌ Redis FLUSHALL error:', error);
      throw error;
    }
  }

  async healthCheck() {
    try {
      const start = Date.now();
      await this.client.ping();
      const latency = Date.now() - start;
      
      return {
        status: 'healthy',
        latency: `${latency}ms`,
        memory: await this.client.info('memory'),
        clients: await this.client.info('clients'),
        stats: await this.client.info('stats'),
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        error: error.message,
        details: 'Redis connection failed'
      };
    }
  }

  async close() {
    if (this.client) {
      await this.client.quit();
      await this.subscriber.quit();
      await this.publisher.quit();
      this.isConnected = false;
      logger.info('✅ Redis connections closed');
    }
  }
}

// Singleton instance
const redisClient = new RedisClient();

// Export helper functions
const connectRedis = async () => {
  return await redisClient.connect();
};

const getRedisClient = () => {
  return redisClient;
};

const closeRedis = async () => {
  return await redisClient.close();
};

module.exports = {
  redisClient,
  connectRedis,
  getRedisClient,
  closeRedis,
  // Export common operations
  set: async (key, value, ttl) => await redisClient.set(key, value, ttl),
  get: async (key) => await redisClient.get(key),
  del: async (key) => await redisClient.del(key),
  exists: async (key) => await redisClient.exists(key),
  expire: async (key, ttl) => await redisClient.expire(key, ttl),
  incr: async (key) => await redisClient.incr(key),
  publish: async (channel, message) => await redisClient.publish(channel, message),
  subscribe: async (channel, callback) => await redisClient.subscribe(channel, callback),
  healthCheck: async () => await redisClient.healthCheck(),
};