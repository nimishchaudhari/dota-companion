# GitHub Actions Workflows

## CI/CD Pipeline Workflow
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 16
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Run linting
        run: npm run lint
      - name: Check formatting
        run: npm run format:check
```

## End-to-End Testing Workflow
```yaml
name: End-to-End Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 1-5'  # Run every weekday at 2 AM
  workflow_dispatch:      # Allow manual triggering

jobs:
  e2e-tests:
    name: E2E Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 16
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Install Playwright dependencies
        run: npx playwright install --with-deps
      - name: Build applications
        run: npm run build
      - name: Run E2E tests
        run: npm run test:e2e
```

## Security Scanning Workflow
```yaml
name: Security Scans

on:
  schedule:
    - cron: '0 0 * * 0'  # Run weekly on Sundays at midnight
  workflow_dispatch:     # Allow manual triggering

jobs:
  dependency-scan:
    name: Dependency Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 16
      - name: Install dependencies
        run: npm ci
      - name: Run npm audit
        run: npm audit
```

## Deployment Workflow
```yaml
name: Continuous Deployment

on:
  push:
    branches:
      - main
      - staging
      - production
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'dev'
        type: choice
        options:
          - dev
          - staging
          - production

jobs:
  build-push-deploy:
    name: Build, Push, and Deploy
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
```

## Package Publishing Workflow
```yaml
name: Publish Packages

on:
  release:
    types: [created]

jobs:
  build-and-publish:
    name: Build and Publish NPM Packages
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 16
          registry-url: 'https://registry.npmjs.org'
      - name: Install dependencies
        run: npm ci
      - name: Build packages
        run: npm run build
      - name: Publish packages
        run: npm publish --workspaces --access public
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```