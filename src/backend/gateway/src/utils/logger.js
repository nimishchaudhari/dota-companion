const pino = require('pino');
const config = require('../config');

const options = {
  level: config.logging.level,
  mixin: () => {
    return {
      service: 'gateway',
      environment: config.env,
    };
  },
  redact: {
    paths: [
      'req.headers.authorization',
      'req.headers.cookie',
      'password',
      'apiKey',
      '*.password',
      '*.apiKey',
      '*.token',
      '*.secret',
    ],
    censor: '[REDACTED]',
  },
};

// Use pretty-print in development
if (config.logging.prettyPrint || config.env !== 'production') {
  options.transport = {
    target: 'pino-pretty',
    options: {
      colorize: true,
      translateTime: 'SYS:standard',
      ignore: 'pid,hostname',
    },
  };
}

const logger = pino(options);

// Log uncaught exceptions and unhandled promise rejections
process.on('uncaughtException', (error) => {
  logger.fatal(error, 'Uncaught exception');
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.fatal({ reason }, 'Unhandled promise rejection');
  process.exit(1);
});

module.exports = logger;
