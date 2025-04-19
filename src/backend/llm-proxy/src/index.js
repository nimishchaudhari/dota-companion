const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { createProxyMiddleware } = require('http-proxy-middleware');
const { decrypt } = require('./utils/crypto');
const logger = require('./utils/logger');
const config = require('./config');
const { setupMetrics, trackLLMRequest } = require('./metrics');
const { errorMiddleware } = require('./middleware/error');
const providerRoutes = require('./routes/providers');

// Create Express app
const app = express();

// Middlewares
app.use(cors());
app.use(helmet({ contentSecurityPolicy: false }));
app.use(express.json());

// Setup Prometheus metrics
const { metricsMiddleware } = setupMetrics();
app.use('/metrics', metricsMiddleware);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// LLM proxy route
app.post('/v1/llm/chat', async (req, res) => {
  const { provider, model, apiKeyCiphertext, nonce, messages } = req.body;
  
  if (!provider || !model || !apiKeyCiphertext || !nonce || !messages) {
    return res.status(400).json({ error: 'Missing required parameters' });
  }
  
  try {
    // Decrypt API key
    const apiKey = decrypt(apiKeyCiphertext, nonce);
    
    // Track LLM request start
    const requestId = trackLLMRequest(provider, model);
    
    // Call the appropriate provider handler
    const response = await providerRoutes.callProvider(provider, {
      model,
      apiKey,
      messages,
      stream: true,
    });
    
    // Set the appropriate headers
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    
    // Stream the response
    response.on('data', (chunk) => {
      res.write(chunk);
    });
    
    response.on('end', () => {
      res.end();
      trackLLMRequest(provider, model, requestId, 'success');
    });
    
    response.on('error', (error) => {
      logger.error(`Error streaming from ${provider}:`, error);
      res.end();
      trackLLMRequest(provider, model, requestId, 'error');
    });
  } catch (error) {
    logger.error(`Error calling ${provider}:`, error);
    
    // Handle different error types
    if (error.response && error.response.status === 401) {
      return res.status(401).json({ error: 'Invalid API key' });
    } else if (error.response && error.response.status === 429) {
      return res.status(429).json({ error: 'Rate limit exceeded' });
    } else if (error.response && error.response.status >= 500) {
      return res.status(502).json({ error: 'Provider service unavailable' });
    } else if (error.code === 'ECONNREFUSED' || error.code === 'ECONNRESET') {
      return res.status(503).json({ error: 'Provider connection failed' });
    } else {
      return res.status(500).json({ error: 'Internal server error' });
    }
  }
});

// Error handling middleware
app.use(errorMiddleware);

// Start server
const port = config.port;
app.listen(port, () => {
  logger.info(`LLM Proxy listening on port ${port}`);
});

// Graceful shutdown
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

function shutdown() {
  logger.info('Shutting down LLM Proxy...');
  process.exit(0);
}

// Handle uncaught exceptions and unhandled rejections
process.on('uncaughtException', (error) => {
  logger.error('Uncaught exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled rejection:', reason);
  process.exit(1);
});
