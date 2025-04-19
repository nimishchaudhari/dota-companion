# Tech Stack and Development Environment

## Frontend Stack
- **PWA**:
  - React 18+ with TypeScript
  - PWA with service worker and Web Push
  - Workbox for offline caching
  - IndexedDB with WebCrypto AES-GCM 256 for API key encryption
  - WebSocket client for real-time communication
- **Electron Overlay**:
  - Electron framework
  - UDP listener for GSI events
  - WebSocket client for backend communication
  - WebSpeech API for text-to-speech

## Backend Stack
- **GraphQL Gateway**:
  - GraphQL Mesh for API federation
  - GraphQL Hive for schema registry
  - WebSocket server for real-time communication
  - Server-Sent Events (SSE) for token streaming
- **LLM Proxy**:
  - Provider-agnostic LLM integration (OpenAI, Anthropic, Mistral)
  - Token streaming support
  - Error handling and graceful degradation
- **Data API**:
  - PostgreSQL 16 for relational data
  - Timescale 2.15 for time-series data
  - Redis for caching

## Infrastructure
- **Deployment Environments**:
  - Dev: Kind cluster with SQLite and self-signed TLS
  - Staging: GKE europe-west1 with PG 16 and Cloudflare CERT
  - Prod: GKE europe-west1 with PG 16 + Timescale 2.15 and Cloudflare CERT
- **CI/CD**:
  - GitHub Actions for lint, test, build containers
  - Argo CD for GitOps sync to clusters
  - Helm charts for Kubernetes deployments
- **Infrastructure as Code**:
  - Terraform for GKE, CloudSQL, Redis Memorystore, Cloudflare resources
- **Observability**:
  - Prometheus for metrics
  - Grafana for dashboards
  - Loki for log aggregation
  - Alertmanager with PagerDuty routing

## Testing Tools
- **Unit Testing**: Jest
- **Integration Testing**: Supertest
- **End-to-End Testing**: Playwright
- **Load Testing**: k6
- **Security Testing**: ZAP (OWASP Top 10 scan)

## Development Environment Setup
- Windows development environment
- Node.js for JavaScript/TypeScript development
- Docker for containerization
- Kubernetes for orchestration
- Git for version control

## Code Style and Conventions
- ESLint for JavaScript/TypeScript linting
- Prettier for code formatting
- TypeScript for type safety
- React hooks for state management
- GraphQL for API queries
- RESTful principles for REST endpoints
- JWT for authentication
- HTTPS for all communications
- WebSockets for real-time events