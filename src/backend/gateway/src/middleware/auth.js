const jwt = require('jsonwebtoken');
const config = require('../config');
const logger = require('../utils/logger');

/**
 * Authentication middleware
 * Validates JWT token and adds user information to request
 */
function authMiddleware(req, res, next) {
  // Skip auth for public routes
  if (isPublicRoute(req.path)) {
    return next();
  }

  const authHeader = req.headers.authorization;
  if (!authHeader) {
    req.user = null;
    return next();
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    req.user = null;
    return next();
  }

  try {
    const decoded = jwt.verify(token, config.jwt.secret);
    req.user = {
      id: decoded.userId,
      steamId: decoded.steamId,
      role: decoded.role || 'FREE',
    };
    logger.debug(`Authenticated user: ${req.user.id} (${req.user.role})`);
  } catch (error) {
    logger.debug(`JWT verification failed: ${error.message}`);
    req.user = null;
  }

  next();
}

/**
 * Validates if a user has the required role
 * @param {Object} user - User object from request
 * @param {Array<string>} allowedRoles - Array of allowed roles
 * @returns {boolean} - Whether the user has one of the allowed roles
 */
function hasRole(user, allowedRoles) {
  if (!user) {
    return false;
  }

  return allowedRoles.includes(user.role);
}

/**
 * Check if a route is public (doesn't require authentication)
 * @param {string} path - Request path
 * @returns {boolean} - Whether the route is public
 */
function isPublicRoute(path) {
  const publicRoutes = [
    '/health',
    '/metrics',
    '/auth/steam',
    '/auth/steam/return',
    '/graphql', // GraphQL uses its own resolver-level auth
  ];

  return publicRoutes.some(route => path.startsWith(route));
}

module.exports = {
  authMiddleware,
  hasRole,
  isPublicRoute,
};
