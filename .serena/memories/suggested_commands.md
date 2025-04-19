# Suggested Commands for Dota Companion Development

## Git Commands
```
git status                           # Check status of repository
git add .                            # Add all changes to staging
git commit -m "message"              # Commit changes with message
git pull                             # Pull latest changes from remote
git push                             # Push changes to remote
git checkout -b feature/branch-name  # Create and switch to new feature branch
git merge feature/branch-name        # Merge branch into current branch
```

## Directory Navigation (Windows)
```
dir                     # List directory contents
cd path\to\directory    # Change directory
cd ..                   # Go up one directory
mkdir directory_name    # Create directory
rmdir directory_name    # Remove directory
type filename           # Display file contents (like cat in Unix)
findstr "text" filename # Search for text in file (like grep in Unix)
```

## Frontend Development (PWA)
```
cd src\frontend\pwa
npm install                # Install dependencies
npm start                  # Start development server
npm run build              # Build production bundle
npm run lint               # Run ESLint
npm run lint:fix           # Fix ESLint issues
npm run format             # Run Prettier
npm test                   # Run Jest tests
npm run test:coverage      # Run tests with coverage
npm run test:e2e           # Run Playwright e2e tests
```

## Overlay Development (Electron)
```
cd src\frontend\overlay
npm install                # Install dependencies
npm start                  # Start development build
npm run build              # Build production app
npm run package            # Package app for distribution
npm run lint               # Run ESLint
npm test                   # Run tests
```

## Backend Development
```
cd src\backend\gateway     # Or llm-proxy or data-api
npm install                # Install dependencies
npm start                  # Start development server
npm run build              # Build for production
npm run lint               # Run ESLint
npm test                   # Run tests
```

## Docker & Kubernetes
```
docker build -t dota-companion/service-name:tag .     # Build docker image
docker run -p 3000:3000 dota-companion/service-name   # Run container
docker-compose up                                     # Start all services
kubectl apply -f kubernetes/service.yaml              # Apply K8s config
kubectl get pods                                      # List running pods
kubectl logs pod-name                                 # View pod logs
```

## Infrastructure
```
cd infrastructure\terraform
terraform init                     # Initialize Terraform
terraform plan                     # Preview changes
terraform apply                    # Apply changes
terraform destroy                  # Destroy resources
```

## Database
```
psql -U postgres -h localhost -d dota_companion    # Connect to PostgreSQL
redis-cli                                          # Connect to Redis CLI
```

## Deployment
```
npm run deploy:dev                 # Deploy to dev environment
npm run deploy:staging             # Deploy to staging environment
npm run deploy:prod                # Deploy to production environment
```

## Testing
```
npm run test:unit                  # Run unit tests
npm run test:integration           # Run integration tests
npm run test:e2e                   # Run end-to-end tests
npm run test:load                  # Run k6 load tests
npm run test:security              # Run ZAP security tests
```

## CI/CD
```
gh workflow run workflow_name      # Manually run GitHub Actions workflow
argocd app sync app-name           # Sync ArgoCD application
```

## Monitoring & Debugging
```
kubectl port-forward svc/grafana 3000:3000              # Access Grafana dashboard
kubectl port-forward svc/prometheus 9090:9090           # Access Prometheus
kubectl port-forward svc/alertmanager 9093:9093         # Access Alertmanager
kubectl logs -f deployment/service-name                 # Follow logs of a deployment
```