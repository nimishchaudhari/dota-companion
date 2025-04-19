require('dotenv').config();

const config = {
  // Server configuration
  port: process.env.PORT || 4001,
  env: process.env.NODE_ENV || 'development',
  
  // Encryption settings for WebCrypto AES-GCM
  encryption: {
    algorithm: 'AES-GCM',
    keyLength: 256,
    ivLength: 12,
  },
  
  // Logging configuration
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    prettyPrint: process.env.LOG_PRETTY === 'true',
  },
  
  // Provider base URLs
  providers: {
    openai: {
      baseUrl: process.env.OPENAI_BASE_URL || 'https://api.openai.com',
      supportedModels: ['gpt-4o', 'gpt-4o-mini', 'gpt-4', 'gpt-3.5-turbo'],
      defaultModel: 'gpt-3.5-turbo',
    },
    anthropic: {
      baseUrl: process.env.ANTHROPIC_BASE_URL || 'https://api.anthropic.com',
      supportedModels: ['claude-3-opus', 'claude-3-sonnet', 'claude-3-haiku'],
      defaultModel: 'claude-3-haiku',
    },
    mistral: {
      baseUrl: process.env.MISTRAL_BASE_URL || 'https://api.mistral.ai',
      supportedModels: ['mistral-small', 'mistral-medium', 'mistral-large'],
      defaultModel: 'mistral-small',
    },
  },
  
  // Retry configuration
  retry: {
    maxRetries: 3,
    initialDelayMs: 1000,
    maxDelayMs: 10000,
  },
  
  // Timeout configuration
  timeout: {
    request: 60000, // 60 seconds
    firstToken: 10000, // 10 seconds
  },
  
  // CORS configuration
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
  },
  
  // Cache configuration
  cache: {
    enabled: process.env.CACHE_ENABLED === 'true',
    ttl: parseInt(process.env.CACHE_TTL || '300', 10), // 5 minutes
  },
  
  // Prometheus metrics
  metrics: {
    enabled: true,
    prefix: 'llm_proxy_',
  },
};

module.exports = config;
