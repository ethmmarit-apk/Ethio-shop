const App = require('./app');
const { logger } = require('./utils/logger');
const { connectDatabase } = require('./config/database');
const { connectRedis } = require('./config/redis');
const { initializeFirebase } = require('./config/firebase');
const { initializeSocketIO } = require('./config/socket');
const { initializeCronJobs } = require('./utils/cronJobs');
const { checkRequiredEnvVars } = require('./utils/envChecker');

// Load environment variables
require('dotenv').config();

// Check required environment variables
checkRequiredEnvVars();

// Initialize application
const app = new App();

// Initialize services
const initializeServices = async () => {
  try {
    logger.info('🚀 Initializing Ethio Shop Backend Services...');

    // 1. Connect to PostgreSQL
    logger.info('📊 Connecting to PostgreSQL database...');
    await connectDatabase();
    logger.info('✅ PostgreSQL connected successfully');

    // 2. Connect to Redis
    logger.info('🔴 Connecting to Redis cache...');
    await connectRedis();
    logger.info('✅ Redis connected successfully');

    // 3. Initialize Firebase
    logger.info('🔥 Initializing Firebase services...');
    await initializeFirebase();
    logger.info('✅ Firebase initialized successfully');

    // 4. Initialize Socket.IO (if enabled)
    if (process.env.SOCKET_ENABLED === 'true') {
      logger.info('💬 Initializing Socket.IO...');
      initializeSocketIO(app.app);
      logger.info('✅ Socket.IO initialized successfully');
    }

    // 5. Initialize cron jobs (if enabled)
    if (process.env.ENABLE_CRON_JOBS === 'true') {
      logger.info('⏰ Initializing cron jobs...');
      initializeCronJobs();
      logger.info('✅ Cron jobs initialized successfully');
    }

    // 6. Run database migrations
    if (process.env.RUN_MIGRATIONS === 'true') {
      logger.info('🗄️ Running database migrations...');
      const { runMigrations } = require('./db/migrate');
      await runMigrations();
      logger.info('✅ Database migrations completed');
    }

    // 7. Seed database (only in development)
    if (process.env.NODE_ENV === 'development' && process.env.SEED_DATABASE === 'true') {
      logger.info('🌱 Seeding database with sample data...');
      const { seedDatabase } = require('./db/seed');
      await seedDatabase();
      logger.info('✅ Database seeding completed');
    }

    logger.info('🎉 All services initialized successfully!');
    
    // Start the server
    app.start();

  } catch (error) {
    logger.error('❌ Failed to initialize services:', error);
    process.exit(1);
  }
};

// Handle server errors
const handleServerErrors = () => {
  process.on('uncaughtException', (error) => {
    logger.error('🔥 Uncaught Exception:', error);
    process.exit(1);
  });

  process.on('unhandledRejection', (reason, promise) => {
    logger.error('🔥 Unhandled Rejection at:', promise, 'reason:', reason);
    process.exit(1);
  });
};

// Application entry point
if (require.main === module) {
  handleServerErrors();
  initializeServices();
}

module.exports = app;