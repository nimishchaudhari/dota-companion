const prometheus = require('prometheus-client');
const logger = require('./utils/logger');

/**
 * Setup Prometheus metrics
 */
function setupPrometheus() {
  // Create registry
  const registry = new prometheus.Registry();
  
  // Add default metrics
  prometheus.collectDefaultMetrics({ registry });
  
  // Custom metrics
  const httpRequestDurationMicroseconds = new prometheus.Summary({
    name: 'request_duration_seconds',
    help: 'HTTP request duration in seconds',
    labelNames: ['method', 'route', 'status_code'],
    percentiles: [0.5, 0.9, 0.95, 0.99],
    registers: [registry],
  });
  
  const httpRequestCounter = new prometheus.Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route', 'status_code'],
    registers: [registry],
  });
  
  const websocketConnections = new prometheus.Gauge({
    name: 'websocket_connections',
    help: 'Current number of WebSocket connections',
    registers: [registry],
  });
  
  const websocketMessagesSent = new prometheus.Counter({
    name: 'websocket_messages_sent_total',
    help: 'Total number of WebSocket messages sent',
    registers: [registry],
  });
  
  const websocketMessagesReceived = new prometheus.Counter({
    name: 'websocket_messages_received_total',
    help: 'Total number of WebSocket messages received',
    registers: [registry],
  });
  
  const graphqlOperationCounter = new prometheus.Counter({
    name: 'graphql_operations_total',
    help: 'Total number of GraphQL operations',
    labelNames: ['operation', 'type'],
    registers: [registry],
  });
  
  const graphqlErrorCounter = new prometheus.Counter({
    name: 'graphql_errors_total',
    help: 'Total number of GraphQL errors',
    labelNames: ['operation', 'error_code'],
    registers: [registry],
  });
  
  // Middleware for Express
  const metricsMiddleware = (req, res) => {
    res.set('Content-Type', prometheus.register.contentType);
    res.end(prometheus.register.metrics());
  };
  
  // Middleware for measuring HTTP request duration
  const durationMiddleware = (req, res, next) => {
    const start = Date.now();
    
    // Record end time and duration on response finish
    res.on('finish', () => {
      const duration = (Date.now() - start) / 1000;
      const route = req.route ? req.route.path : req.path;
      const method = req.method;
      const statusCode = res.statusCode;
      
      httpRequestDurationMicroseconds
        .labels(method, route, statusCode)
        .observe(duration);
      
      httpRequestCounter
        .labels(method, route, statusCode)
        .inc();
      
      logger.debug(`${method} ${route} ${statusCode} - ${duration.toFixed(3)}s`);
    });
    
    next();
  };
  
  // Track websocket metrics
  const trackWebSocketConnection = (connected = true) => {
    if (connected) {
      websocketConnections.inc();
    } else {
      websocketConnections.dec();
    }
  };
  
  const trackWebSocketMessageSent = () => {
    websocketMessagesSent.inc();
  };
  
  const trackWebSocketMessageReceived = () => {
    websocketMessagesReceived.inc();
  };
  
  // Track GraphQL metrics
  const trackGraphQLOperation = (operation, type) => {
    graphqlOperationCounter.labels(operation, type).inc();
  };
  
  const trackGraphQLError = (operation, errorCode) => {
    graphqlErrorCounter.labels(operation, errorCode).inc();
  };
  
  return {
    registry,
    metricsMiddleware,
    durationMiddleware,
    trackWebSocketConnection,
    trackWebSocketMessageSent,
    trackWebSocketMessageReceived,
    trackGraphQLOperation,
    trackGraphQLError,
  };
}

module.exports = {
  setupPrometheus,
};
