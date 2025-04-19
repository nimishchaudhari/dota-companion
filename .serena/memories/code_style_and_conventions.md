# Code Style and Conventions

## General Guidelines
- Use TypeScript for all new code
- Follow the principle of least privilege
- Write unit tests for all business logic
- Document public APIs with JSDoc comments
- Use meaningful variable and function names
- Keep functions small and focused on a single responsibility
- Use async/await for asynchronous code
- Handle errors properly with try/catch blocks
- Never log sensitive information (API keys, user data)

## Naming Conventions
- **Variables and Functions**: camelCase
- **Classes and Interfaces**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **File Names**: kebab-case.ts
- **Component Files**: PascalCase.tsx
- **Test Files**: filename.test.ts or filename.spec.ts

## TypeScript Guidelines
- Enable strict mode in tsconfig.json
- Use explicit types for function parameters and return values
- Prefer interfaces over type aliases for object definitions
- Use enums for well-defined sets of values
- Use readonly for immutable properties
- Avoid using any type unless absolutely necessary
- Use type guards for runtime type checking

## React Guidelines
- Use functional components with hooks
- Use React.FC for component type definitions
- Destructure props in component parameters
- Use custom hooks for shared logic
- Keep components small and focused
- Use React.memo for expensive components
- Follow the React hooks rules
- Use CSS-in-JS or CSS modules for styling

## GraphQL Guidelines
- Use descriptive names for queries and mutations
- Keep queries as specific as possible
- Use fragments for sharing common fields
- Document all types and fields with descriptions
- Use input types for complex mutation arguments
- Follow naming conventions for GraphQL types and fields

## REST API Guidelines
- Follow RESTful principles
- Use nouns for resource endpoints
- Use HTTP methods appropriately (GET, POST, PUT, DELETE)
- Return appropriate HTTP status codes
- Use query parameters for filtering and pagination
- Use JSON for request and response bodies
- Version your APIs with /v1/ prefix

## Security Guidelines
- Encrypt sensitive data (API keys, tokens)
- Validate all user inputs
- Use parameterized queries for database access
- Set appropriate security headers
- Follow the principle of least privilege
- Never store secrets in code or version control
- Use HTTPS for all communications

## Testing Guidelines
- Aim for 80% unit test coverage
- Mock external dependencies
- Use descriptive test names
- Follow the Arrange-Act-Assert pattern
- Write integration tests for API endpoints
- Write e2e tests for critical user flows
- Use snapshot tests sparingly

## Commit Message Guidelines
- Use the format: `type(scope): subject`
- Types: feat, fix, docs, style, refactor, test, chore
- Keep subject line under 50 characters
- Use imperative mood in subject line
- Provide detailed description if necessary

## Documentation Guidelines
- Use JSDoc for API documentation
- Document complex algorithms and business logic
- Keep README files up to date
- Document environment variables
- Use diagrams for complex flows or architectures