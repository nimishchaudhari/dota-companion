# Dota Companion Project Overview

## Project Purpose
Dota Companion is a browser-based, VAC-safe companion web application for Dota 2 that:

1. Streams only Valve-approved Game State Integration (GSI) telemetry
2. Combines it with public match data from OpenDota & STRATZ
3. Feeds compact event frames to a user-supplied Large-Language-Model (LLM) for personalized coaching
4. Presents the results as overlays, dashboards, and push notifications on any device

## Key Differentiators
- Zero installs on mobiles – delivered as a Progressive Web App (PWA)
- Users keep control of their AI provider choice & API key (OpenAI, Mistral, Anthropic, etc.)
- 100% VAC-safe (no memory reads, no DLL injections)

## Tech Stack
- **Frontend**: 
  - PWA: React with TypeScript, Workbox for offline caching
  - Overlay: Electron application
- **Backend**: 
  - GraphQL Gateway (using GraphQL Mesh + Hive)
  - LLM Proxy (stateless)
  - Data API
- **Databases**: 
  - PostgreSQL 16
  - Timescale 2.15 for time-series data
  - Redis Memorystore for caching
- **Infrastructure**: 
  - Google Kubernetes Engine (GKE)
  - Terraform for infrastructure-as-code
  - Argo CD for GitOps
  - Helm charts for deployment
  - GitHub Actions for CI/CD
  - Prometheus, Grafana, Loki for observability

## Project Structure
```
dota-companion/
├── src/
│   ├── frontend/
│   │   ├── pwa/         # React PWA application
│   │   └── overlay/     # Electron overlay application
│   └── backend/
│       ├── gateway/     # GraphQL Gateway service
│       ├── llm-proxy/   # LLM Proxy service
│       └── data-api/    # Data API service
├── docs/
│   └── architecture/    # Architecture documentation
├── infrastructure/
│   └── terraform/       # Terraform IaC
└── SRS.md               # Software Requirements Specification
```

## Key Functional Requirements
- Steam OpenID 2.0 authentication
- Client-side encryption of LLM API keys
- Draft assistant with counter suggestions
- Match history with timeline charts
- Replay clip generation
- Pro-match alerts via push notifications
- Progressive Web App with offline capabilities

## Non-Functional Requirements
- Latency: Overlay → First coach word ≤ 200 ms p95 EU West
- Scaling: 20k concurrent overlays, 200 req/s GraphQL
- Uptime: 99.5% Monthly
- Privacy: API keys client-only, never logged
- GDPR: Right-to-delete ≤ 24h
- Accessibility: WCAG 2.2 AA
- Quality: Unit ≥ 80%, e2e (Playwright) ≥ 20 critical flows

## Target Launch Date
November 21, 2025