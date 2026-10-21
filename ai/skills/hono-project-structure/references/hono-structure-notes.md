# Hono structure notes

Use these Hono-specific constraints when applying the project-structure rules.

## Route composition

- Prefer Hono sub-applications and `app.route()` for larger applications.
- Keep handlers attached to route definitions when possible to preserve path and request type inference.
- Avoid Rails-style controller extraction by default.
- If handlers must be extracted, prefer `createFactory()` / `factory.createHandlers()` patterns that preserve Hono typing.

Official references:
- https://hono.dev/docs/guides/best-practices
- https://hono.dev/docs/api/routing

## RPC and typed clients

- Preserve chained route definitions when exporting `typeof app` for Hono Client/RPC.
- Compose route apps carefully so the final application type includes mounted routes.
- For large RPC applications, splitting clients/apps by domain can reduce type-instantiation/IDE performance costs.
- Keep TypeScript strict mode enabled when required for RPC inference across packages/monorepos.

Official references:
- https://hono.dev/docs/guides/rpc
- https://hono.dev/examples/grouping-routes-rpc

## Middleware and Context

- Use `createMiddleware()` when extracting custom middleware to retain Context typing.
- Prefer typed `Variables`/`Env` boundaries.
- Treat global `ContextVariableMap` augmentation carefully because it can make a value appear globally available even where its middleware has not run.
- Use global augmentation only for variables guaranteed to be set application-wide.

Official references:
- https://hono.dev/docs/guides/middleware
- https://hono.dev/docs/api/context

## Validation

- Hono's validator is intentionally thin and may be combined with third-party validators.
- Keep schemas close to the feature/subfeature whose request contract they represent.
- Validation technology does not determine architectural ownership.

Official reference:
- https://hono.dev/docs/guides/validation

## Testing

- Hono apps can be tested by sending requests directly with `app.request()`.
- `testClient()` provides typed route calls.
- Typed `testClient()` inference depends on chained route definitions, so structure route apps accordingly when that feature is desired.
- Runtime-specific test setup can differ; keep that setup at the appropriate runtime/E2E boundary.

Official references:
- https://hono.dev/docs/guides/testing
- https://hono.dev/docs/helpers/testing

## Multi-runtime constraint

Hono supports multiple JavaScript runtimes. Keep runtime-specific adapters, bindings, compatibility flags, and deployment configuration separate from portable business logic whenever practical. Do not introduce abstractions solely for hypothetical future runtimes.
