const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const slowDown = require('express-slow-down');
const morgan = require('morgan');
const { errors } = require('celebrate');
const swaggerUi = require('swagger-ui-express');
const swaggerSpecs = require('./config/swagger');
const { logger, requestLogger } = require('./utils/logger');
const errorHandler = require('./middleware/errorHandler');
const notFoundHandler = require('./middleware/notFoundHandler');
const ethiopianMiddleware = require('./middleware/ethiopianMiddleware');
const requestId = require('./middleware/requestId');
const responseTime = require('./middleware/responseTime');
const cache = require('./middleware/cache');

// Load environment variables
require('dotenv').config();

class App {
  constructor() {
    this.app = express();
    this.port = process.env.PORT || 8080;
    this.environment = process.env.NODE_ENV || 'development';

    this.initializeMiddlewares();
    this.initializeRoutes();
    this.initializeErrorHandling();
    this.initializeSwagger();
  }

  initializeMiddlewares() {
    // Security middleware
    this.app.use(helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
          imgSrc: ["'self'", "data:", "https:", "blob:"],
          connectSrc: ["'self'", "https://*.firebaseio.com", "wss://*.firebaseio.com"],
          fontSrc: ["'self'", "https://fonts.gstatic.com"],
          objectSrc: ["'none'"],
          mediaSrc: ["'self'"],
          frameSrc: ["'none'"],
        },
      },
    }));

    // CORS configuration
    const allowedOrigins = process.env.ALLOWED_ORIGINS
      ? process.env.ALLOWED_ORIGINS.split(',')
      : ['http://localhost:3000', 'http://localhost:8080'];

    this.app.use(cors({
      origin: (origin, callback) => {
        if (!origin || allowedOrigins.indexOf(origin) !== -1) {
          callback(null, true);
        } else {
          callback(new Error('Not allowed by CORS'));
        }
      },
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin', 'X-Currency', 'Accept-Language'],
      exposedHeaders: ['X-Request-ID', 'X-Response-Time', 'X-API-Version'],
    }));

    // Rate limiting
    const limiter = rateLimit({
      windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
      max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
      message: {
        success: false,
        error: 'Too many requests from this IP, please try again later.',
        retryAfter: '15 minutes'
      },
      standardHeaders: true,
      legacyHeaders: false,
      skipSuccessfulRequests: false,
      keyGenerator: (req) => {
        return req.ip || req.connection.remoteAddress;
      },
    });

    // Slow down
    const speedLimiter = slowDown({
      windowMs: parseInt(process.env.SLOW_DOWN_WINDOW_MS) || 15 * 60 * 1000,
      delayAfter: parseInt(process.env.SLOW_DOWN_DELAY_AFTER) || 100,
      delayMs: parseInt(process.env.SLOW_DOWN_DELAY_MS) || 500,
      maxDelayMs: 20000,
      skipSuccessfulRequests: false,
    });

    // Apply rate limiting to API routes
    this.app.use('/api/', limiter);
    this.app.use('/api/', speedLimiter);

    // Request parsing
    this.app.use(express.json({
      limit: process.env.MAX_FILE_SIZE || '10mb',
      verify: (req, res, buf) => {
        req.rawBody = buf.toString();
      }
    }));
    this.app.use(express.urlencoded({
      extended: true,
      limit: process.env.MAX_FILE_SIZE || '10mb'
    }));

    // Compression
    this.app.use(compression({
      level: 6,
      threshold: 1024,
    }));

    // Custom middleware
    this.app.use(requestId);
    this.app.use(responseTime);
    this.app.use(requestLogger);
    this.app.use(ethiopianMiddleware);

    // Request logging
    if (this.environment !== 'test') {
      this.app.use(morgan('combined', { stream: logger.stream }));
    }

    // Health check endpoint
    this.app.get('/health', (req, res) => {
      const healthcheck = {
        uptime: process.uptime(),
        timestamp: Date.now(),
        service: 'Ethio Shop API',
        version: process.env.npm_package_version || '1.0.0',
        environment: this.environment,
        database: 'connected', // You would check DB connection here
        redis: 'connected', // You would check Redis connection here
        firebase: 'connected', // You would check Firebase connection here
        memory: process.memoryUsage(),
        node: process.version,
      };
      
      res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
      res.set('Pragma', 'no-cache');
      res.set('Expires', '0');
      
      res.status(200).json(healthcheck);
    });

    // API info endpoint
    this.app.get('/api/info', cache(300), (req, res) => {
      res.json({
        name: 'Ethio Shop API',
        version: process.env.npm_package_version || '1.0.0',
        description: 'Backend API for Ethiopian Marketplace',
        environment: this.environment,
        documentation: `${process.env.API_URL || 'http://localhost:8080'}/api-docs`,
        endpoints: {
          auth: '/api/auth',
          users: '/api/users',
          products: '/api/products',
          orders: '/api/orders',
          categories: '/api/categories',
          chat: '/api/chat',
          upload: '/api/upload',
          ethiopia: '/api/ethiopia',
          admin: '/api/admin',
        },
        features: {
          authentication: true,
          productManagement: true,
          orderProcessing: true,
          realTimeChat: true,
          imageUpload: true,
          pushNotifications: true,
          ethiopianFeatures: true,
          multiLanguage: true,
          paymentIntegration: true,
          analytics: true,
        },
        ethiopianFeatures: {
          currency: 'ETB',
          phoneFormat: '+251XXXXXXXXX',
          addressFormat: 'City, Subcity, Woreda, Kebele',
          languages: ['Amharic', 'English', 'Oromo', 'Tigrinya'],
          holidays: true,
          localDelivery: true,
          trustSystem: true,
        },
        support: {
          email: 'support@ethiomarketplace.com',
          documentation: 'https://docs.ethiomarketplace.com',
          issues: 'https://github.com/ethmmarit-apk/Ethio-shop/issues',
        },
      });
    });
  }

  initializeRoutes() {
    // API Routes
    this.app.use('/api/auth', require('./routes/auth'));
    this.app.use('/api/users', require('./routes/users'));
    this.app.use('/api/products', require('./routes/products'));
    this.app.use('/api/categories', require('./routes/categories'));
    this.app.use('/api/orders', require('./routes/orders'));
    this.app.use('/api/chat', require('./routes/chat'));
    this.app.use('/api/upload', require('./routes/upload'));
    this.app.use('/api/ethiopia', require('./routes/ethiopia'));
    this.app.use('/api/admin', require('./routes/admin'));
    
    // Webhook endpoints
    this.app.use('/webhooks/stripe', require('./routes/webhooks/stripe'));
    this.app.use('/webhooks/chapa', require('./routes/webhooks/chapa'));
    
    // Public assets
    this.app.use('/uploads', express.static('uploads', {
      maxAge: '7d',
      setHeaders: (res, path) => {
        res.set('Cache-Control', 'public, max-age=604800');
      }
    }));
  }

  initializeSwagger() {
    if (this.environment !== 'production') {
      this.app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpecs, {
        explorer: true,
        customCss: '.swagger-ui .topbar { display: none }',
        customSiteTitle: 'Ethio Shop API Documentation',
        customfavIcon: '/favicon.ico',
        swaggerOptions: {
          persistAuthorization: true,
          docExpansion: 'list',
          filter: true,
          displayRequestDuration: true,
        }
      }));
      
      this.app.get('/api-docs.json', (req, res) => {
        res.setHeader('Content-Type', 'application/json');
        res.send(swaggerSpecs);
      });
    }
  }

  initializeErrorHandling() {
    // Joi validation errors
    this.app.use(errors());
    
    // 404 handler
    this.app.use(notFoundHandler);
    
    // Global error handler
    this.app.use(errorHandler);
  }

  start() {
    const server = this.app.listen(this.port, () => {
      logger.info(`
🚀 Ethio Shop Backend Server
📡 Port: ${this.port}
🌍 Environment: ${this.environment}
🔗 API URL: ${process.env.API_URL || `http://localhost:${this.port}`}
📚 Docs: ${process.env.API_URL || `http://localhost:${this.port}`}/api-docs
⚡ Health: ${process.env.API_URL || `http://localhost:${this.port}`}/health
⏰ ${new Date().toLocaleString('en-US', { timeZone: 'Africa/Addis_Ababa' })}
      `);
    });

    // Handle graceful shutdown
    const gracefulShutdown = () => {
      logger.info('Received shutdown signal, closing server...');
      
      server.close(() => {
        logger.info('HTTP server closed');
        
        // Close database connections
        const { pool } = require('./config/database');
        if (pool) {
          pool.end(() => {
            logger.info('Database connections closed');
            process.exit(0);
          });
        } else {
          process.exit(0);
        }
      });

      // Force close after 10 seconds
      setTimeout(() => {
        logger.error('Could not close connections in time, forcefully shutting down');
        process.exit(1);
      }, 10000);
    };

    process.on('SIGTERM', gracefulShutdown);
    process.on('SIGINT', gracefulShutdown);

    // Handle uncaught exceptions
    process.on('uncaughtException', (error) => {
      logger.error('Uncaught Exception:', error);
      process.exit(1);
    });

    process.on('unhandledRejection', (reason, promise) => {
      logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
      process.exit(1);
    });

    return server;
  }
}

module.exports = App;