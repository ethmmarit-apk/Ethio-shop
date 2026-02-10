const jwt = require('jsonwebtoken');
const { pool } = require('../app');
const { logger } = require('../utils/logger');

const authenticate = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Authentication required',
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if user exists and is active
    const userResult = await pool.query(
      'SELECT id, email, user_type, verification_status FROM users WHERE id = $1',
      [decoded.userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: 'User not found',
      });
    }

    req.user = userResult.rows[0];
    next();
  } catch (error) {
    logger.error('Authentication error:', error);
    return res.status(401).json({
      success: false,
      error: 'Invalid or expired token',
    });
  }
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.user_type)) {
      return res.status(403).json({
        success: false,
        error: 'Insufficient permissions',
      });
    }
    next();
  };
};

module.exports = { authenticate, authorize };