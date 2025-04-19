# Comprehensive Task List for Dota Companion

## 1. Project Setup & Infrastructure
- [x] Create GitHub repository structure
- [x] Configure ESLint and Prettier for code standards
- [x] Set up GitHub Actions for CI/CD (lint, test, build containers)
- [x] Create Terraform scripts for GKE cluster
- [x] Set up Terraform scripts for CloudSQL (PostgreSQL)
- [x] Configure Terraform for Redis Memorystore
- [x] Set up Cloudflare resources with Terraform
- [x] Create Kubernetes namespaces for dev, staging, and production
- [x] Configure Argo CD for GitOps deployment
- [x] Create Helm charts with environment parameterization
- [x] Set up SealedSecrets for secret management
- [x] Configure Prometheus, Grafana, Loki stack
- [x] Set up Alertmanager with PagerDuty integration
- [x] Create monitoring dashboards for key metrics
- [ ] Configure backup and disaster recovery

## 2. Backend Development
- [x] Set up GraphQL Gateway service
- [x] Configure GraphQL Mesh for OpenDota API integration
- [x] Configure GraphQL Mesh for STRATZ API integration
- [x] Implement GraphQL schema for draft suggestions
- [x] Implement GraphQL schema for live coach ping
- [x] Create LLM Proxy service
- [x] Implement provider-agnostic LLM configuration
- [x] Set up token streaming for LLM responses
- [x] Implement error handling and fallback mechanisms for LLM
- [ ] Create Data API service with PostgreSQL connection
- [ ] Configure Timescale for time-series data
- [ ] Create database schema for users table
- [ ] Create database schema for match_events table
- [ ] Implement Steam OpenID 2.0 login endpoint
- [ ] Create JWT issuance with HS512 algorithm
- [ ] Implement refresh token rotation
- [ ] Set up role-based access control (FREE, PLUS, ADMIN)
- [ ] Create REST endpoint for match list
- [ ] Implement REST endpoint for clip rendering
- [ ] Create REST endpoint for LLM chat proxy
- [ ] Set up WebSocket server for frame events
- [ ] Configure WebSocket server for coach responses
- [ ] Implement GDPR data deletion flow
- [ ] Create nightly job for percentile benchmarks computation

## 3. Frontend Development - PWA
- [ ] Set up React application with TypeScript
- [ ] Configure PWA manifest with icons
- [ ] Implement Workbox for offline caching of heroes and recent matches
- [ ] Create authentication flow with Steam login
- [ ] Build settings screen for LLM provider configuration
- [ ] Implement WebCrypto AES-GCM 256 encryption for API keys
- [ ] Create IndexedDB storage for encrypted keys
- [ ] Build main navigation and app shell
- [ ] Implement match history page with pagination
- [ ] Create match detail view with timeline charts
- [ ] Build draft assistant UI with counter suggestions
- [ ] Implement pro-match alerts subscription UI
- [ ] Set up Firebase Cloud Messaging for push notifications
- [ ] Create Web Push notification handling
- [ ] Build replay clip request and status monitoring UI
- [ ] Implement responsive design for mobile
- [ ] Ensure WCAG 2.2 AA accessibility compliance
- [ ] Create Plus tier feature indicators and upgrade prompts
- [ ] Implement Stripe checkout for Plus subscription

## 4. Overlay Development
- [ ] Set up Electron application
- [ ] Configure UDP listener for GSI events
- [ ] Implement GSI event parsing
- [ ] Create WebSocket client for sending frames
- [ ] Set up WebSocket client for receiving coach responses
- [ ] Build overlay UI components
- [ ] Implement text-to-speech via WebSpeech API
- [ ] Create toggle mechanism for overlay
- [ ] Build mute control for voice feedback
- [ ] Implement toast notifications for key events
- [ ] Create transparency and positioning controls

## 5. Testing & QA
- [ ] Set up Jest for unit testing
- [ ] Write unit tests for utilities
- [ ] Create unit tests for reducers
- [ ] Implement unit tests for prompt builder
- [ ] Set up integration tests with Supertest
- [ ] Create integration tests for authentication
- [ ] Implement integration tests for LLM proxy
- [ ] Write integration tests for GSI ingestion
- [x] Configure Playwright for end-to-end testing
- [x] Create e2e tests for draft flow
- [ ] Implement e2e tests for AI coach voice controls
- [ ] Set up k6 for load testing
- [ ] Create load test for WebSocket connections
- [ ] Implement load test for GraphQL requests
- [x] Configure ZAP for security scanning
- [ ] Run OWASP Top 10 scan
- [ ] Perform accessibility testing
- [ ] Create GDPR compliance test suite

## 6. Launch Preparation
- [ ] Perform final performance optimization
- [ ] Run complete security audit
- [ ] Conduct load testing with 20k concurrent users
- [ ] Create user documentation
- [ ] Prepare launch communications
- [ ] Set up user support channels
- [ ] Configure production monitoring and alerting
- [ ] Validate acceptance criteria:
  - [ ] Verify overlay and PWA installation
  - [ ] Test counter suggestions delivery (within 500ms)
  - [ ] Confirm voice coach speaking within 2s of kill event
  - [ ] Validate match history page with timelines on mobile Safari
  - [ ] Test GDPR delete request flow (< 24h)
  - [ ] Verify 99.5% uptime over 30-day staging soak