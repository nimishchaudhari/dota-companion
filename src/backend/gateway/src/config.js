require('dotenv').config();

const config = {
  // Server configuration
  port: process.env.PORT || 4000,
  env: process.env.NODE_ENV || 'development',
  
  // JWT configuration
  jwt: {
    secret: process.env.JWT_SECRET || 'development-secret-do-not-use-in-production',
    expiresIn: process.env.JWT_EXPIRES_IN || '4h',
    refreshSecret: process.env.REFRESH_SECRET || 'refresh-secret-do-not-use-in-production',
    refreshExpiresIn: process.env.REFRESH_EXPIRES_IN || '7d',
  },
  
  // External APIs
  opendota: {
    apiKey: process.env.OPENDOTA_API_KEY || '',
    baseUrl: process.env.OPENDOTA_BASE_URL || 'https://api.opendota.com/api',
  },
  
  stratz: {
    apiKey: process.env.STRATZ_API_KEY || '',
    baseUrl: process.env.STRATZ_BASE_URL || 'https://api.stratz.com/api',
  },
  
  // Database configuration
  database: {
    host: process.env.POSTGRES_HOST || 'localhost',
    port: parseInt(process.env.POSTGRES_PORT || '5432', 10),
    username: process.env.POSTGRES_USER || 'postgres',
    password: process.env.POSTGRES_PASSWORD || 'postgres',
    database: process.env.POSTGRES_DB || 'dota_companion',
  },
  
  // Redis configuration
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379', 10),
    password: process.env.REDIS_PASSWORD || '',
  },
  
  // LLM Proxy configuration
  llmProxy: {
    url: process.env.LLM_PROXY_URL || 'http://localhost:4001',
  },
  
  // GraphQL Hive configuration
  hive: {
    enabled: process.env.HIVE_ENABLED === 'true',
    token: process.env.HIVE_TOKEN || '',
  },
  
  // Steam API configuration
  steam: {
    apiKey: process.env.STEAM_API_KEY || '',
    realm: process.env.STEAM_REALM || 'http://localhost:4000',
    returnUrl: process.env.STEAM_RETURN_URL || 'http://localhost:4000/auth/steam/return',
  },
  
  // Logging configuration
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    prettyPrint: process.env.LOG_PRETTY === 'true',
  },
  
  // CORS configuration
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
  },
};

// Validate critical configuration
if (config.env === 'production') {
  if (config.jwt.secret === 'development-secret-do-not-use-in-production') {
    throw new Error('JWT_SECRET must be set in production');
  }
  if (config.jwt.refreshSecret === 'refresh-secret-do-not-use-in-production') {
    throw new Error('REFRESH_SECRET must be set in production');
  }
  if (!config.opendota.apiKey) {
    throw new Error('OPENDOTA_API_KEY must be set in production');
  }
  if (!config.stratz.apiKey) {
    throw new Error('STRATZ_API_KEY must be set in production');
  }
  if (!config.steam.apiKey) {
    throw new Error('STEAM_API_KEY must be set in production');
  }
}

module.exports = config;
