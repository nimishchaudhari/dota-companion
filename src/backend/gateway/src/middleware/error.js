const logger = require('../utils/logger');

/**
 * Global error handling middleware
 */
function errorMiddleware(err, req, res, next) {
  const status = err.status || 500;
  const message = err.message || 'Internal Server Error';
  
  // Log all 5xx errors, but only debug log 4xx errors
  if (status >= 500) {
    logger.error(`Error: ${message}`, {
      status,
      stack: err.stack,
      path: req.path,
      method: req.method,
    });
  } else {
    logger.debug(`Client error: ${message}`, {
      status,
      path: req.path,
      method: req.method,
    });
  }
  
  // Don't expose stack traces in production
  const response = {
    error: {
      message,
      status,
      ...(process.env.NODE_ENV !== 'production' && { stack: err.stack }),
    },
  };
  
  res.status(status).json(response);
}

/**
 * Error class for API errors
 */
class ApiError extends Error {
  constructor(message, status = 500) {
    super(message);
    this.status = status;
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
  
  static badRequest(message = 'Bad Request') {
    return new ApiError(message, 400);
  }
  
  static unauthorized(message = 'Unauthorized') {
    return new ApiError(message, 401);
  }
  
  static forbidden(message = 'Forbidden') {
    return new ApiError(message, 403);
  }
  
  static notFound(message = 'Not Found') {
    return new ApiError(message, 404);
  }
  
  static tooManyRequests(message = 'Too Many Requests') {
    return new ApiError(message, 429);
  }
  
  static internal(message = 'Internal Server Error') {
    return new ApiError(message, 500);
  }
}

module.exports = {
  errorMiddleware,
  ApiError,
};
