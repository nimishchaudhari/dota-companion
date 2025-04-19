const express = require('express');
const { ApolloServer } = require('apollo-server-express');
const http = require('http');
const cors = require('cors');
const helmet = require('helmet');
const { WebSocketServer } = require('ws');
const { useServer } = require('graphql-ws/lib/use/ws');
const { execute, subscribe } = require('graphql');
const { createClient } = require('@graphql-hive/client');
const { getMeshSDK, getMeshOptions, getSchema } = require('./mesh');
const { authMiddleware } = require('./middleware/auth');
const { errorMiddleware } = require('./middleware/error');
const { setupPrometheus } = require('./metrics');
const logger = require('./utils/logger');
const config = require('./config');

async function startServer() {
  logger.info('Starting GraphQL Gateway...');
  
  // Initialize Mesh
  const meshOptions = await getMeshOptions();
  const schemaWithExecutor = await getSchema(meshOptions);
  const meshSdk = await getMeshSDK(schemaWithExecutor);
  
  // Create Express app
  const app = express();
  
  // Middlewares
  app.use(cors());
  app.use(helmet({ contentSecurityPolicy: false }));
  app.use(express.json());
  app.use(authMiddleware);
  
  // Prometheus metrics
  const { metricsMiddleware } = setupPrometheus();
  app.use('/metrics', metricsMiddleware);
  
  // Health check endpoint
  app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok' });
  });
  
  // Create Apollo Server
  const server = new ApolloServer({
    schema: schemaWithExecutor,
    context: ({ req }) => ({
      req,
      user: req.user,
      meshSdk,
    }),
    plugins: [
      // Hive schema registry plugin (if enabled)
      ...(config.hive.enabled ? [createClient({
        token: config.hive.token,
        reporting: {
          author: 'gateway',
          commit: process.env.GIT_COMMIT || 'local',
        },
      }).plugin] : []),
    ],
  });
  
  await server.start();
  server.applyMiddleware({ app, path: '/graphql' });
  
  // Create HTTP server
  const httpServer = http.createServer(app);
  
  // Set up WebSocket server for GraphQL subscriptions
  const wsServer = new WebSocketServer({
    server: httpServer,
    path: '/graphql',
  });
  
  useServer(
    {
      schema: schemaWithExecutor,
      execute,
      subscribe,
      context: (ctx) => {
        // WebSocket context setup
        const token = ctx.connectionParams?.token || '';
        // Token validation logic here
        return {
          user: { /* user info from token */ },
          meshSdk,
        };
      },
      onConnect: (ctx) => {
        logger.info('WebSocket connected');
      },
      onDisconnect: (ctx) => {
        logger.info('WebSocket disconnected');
      },
    },
    wsServer
  );
  
  // Error handling middleware must be last
  app.use(errorMiddleware);
  
  // Start the server
  const port = config.port;
  httpServer.listen(port, () => {
    logger.info(`🚀 GraphQL Gateway ready at http://localhost:${port}${server.graphqlPath}`);
    logger.info(`🔌 WebSocket server ready at ws://localhost:${port}${server.graphqlPath}`);
  });
  
  // Graceful shutdown
  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
  
  function shutdown() {
    logger.info('Shutting down GraphQL Gateway...');
    httpServer.close(() => {
      logger.info('HTTP server closed');
      process.exit(0);
    });
  }
}

startServer().catch((error) => {
  logger.error('Failed to start server:', error);
  process.exit(1);
});
