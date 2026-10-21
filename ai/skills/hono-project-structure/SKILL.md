---
name: hono-project-structure
description: Enforce project file and folder placement conventions for Hono TypeScript applications across runtimes such as Cloudflare Workers, Node.js, Bun, and Deno. Use when creating, moving, reviewing, or deciding where to place Hono app composition, routes, handlers, middleware, validation schemas, services, repositories, database infrastructure, context types, utilities, tests, runtime adapters, or domain-specific code. Apply feature/domain-first organization, colocation, nearest-common-ancestor placement, progressive promotion, and Hono-native route composition without imposing controller-heavy framework patterns.
---

# Hono Project Structure

Organize Hono applications by business feature/domain first and technical responsibility second. Preserve Hono's lightweight composition model instead of reproducing NestJS, Rails, or Express controller architectures.

## Core philosophy

Apply these rules in order:

1. Organize business code by feature/domain first.
2. Colocate code with the smallest semantic scope that owns it.
3. Use the nearest common ancestor of all current consumers.
4. Promote only after real reuse appears: subfeature -> domain -> shared.
5. Keep runtime/framework infrastructure separate from business ownership.
6. Keep `shared` domain-agnostic; never use it as a miscellaneous bucket.
7. Do not create speculative empty directories.
8. Prefer Hono-native route composition and type inference over controller abstractions.

## Canonical top-level structure

Use this as an allowed structure, not a requirement to pre-create every directory:

```text
src/
├── index.ts
├── app.ts
├── core/
│   ├── config/
│   ├── database/
│   ├── errors/
│   ├── logging/
│   └── middleware/
├── features/
│   ├── auth/
│   ├── users/
│   ├── clients/
│   └── orders/
├── shared/
│   ├── middleware/
│   ├── validation/
│   ├── types/
│   └── utils/
└── test/
```

Runtime configuration such as `wrangler.jsonc`, `wrangler.toml`, `deno.json`, or Node/Bun entry configuration belongs at the project/configuration boundary required by that runtime, not inside a business feature.

## Bootstrap and app composition

Keep the runtime entry point thin. Prefer:

```text
src/index.ts   # runtime/export/bootstrap boundary
src/app.ts     # Hono application composition
```

Use `app.ts` to compose the application, register global middleware/error handling, and mount feature sub-applications. Keep deployment/runtime-specific bootstrap details in `index.ts` or the adapter/configuration location required by the target runtime.

Do not put business handlers directly into the runtime bootstrap once the application has meaningful feature boundaries.

Conceptually:

```text
runtime
  -> index.ts
      -> app.ts
          -> global infrastructure
          -> feature routes
```

If a runtime's standard template naturally uses a single entry file for a very small application, keep it simple. Split `app.ts` when doing so materially improves composition, testing, or portability.

## Features and route ownership

Place business routes under their owning domain:

```text
src/features/clients/
├── clients.routes.ts
├── clients.service.ts
├── schemas/
├── repositories/
├── types/
└── utils/
```

Mount feature route applications from the composition root with Hono's `app.route()` pattern.

Prefer route modules/sub-applications over a global technical directory such as:

```text
src/routes/
src/controllers/
src/services/
```

that mixes unrelated domains.

## Do not impose controllers by default

Do not create Rails/NestJS-style controllers merely to move route handlers into another file. Hono's type inference is strongest when handlers remain attached to route definitions.

Prefer:

```text
features/books/books.routes.ts
```

with Hono route definitions and handlers colocated.

If handler extraction is genuinely useful, preserve Hono typing with framework-supported factory patterns such as `createFactory()` / `factory.createHandlers()` rather than untyped generic `Context` controllers.

Treat `controller/` as an exceptional project-specific choice, not part of the canonical structure.

## Large domains and subfeatures

When a domain grows, split by business capability rather than by global technical layer:

```text
features/orders/
├── orders.routes.ts
├── repositories/
│   └── orders.repository.ts
├── types/
├── create-order/
│   ├── create-order.routes.ts
│   ├── create-order.service.ts
│   └── create-order.schema.ts
├── cancel-order/
│   ├── cancel-order.routes.ts
│   └── cancel-order.service.ts
└── order-history/
    ├── order-history.routes.ts
    └── order-history.service.ts
```

Keep an artifact in a subfeature while only that subfeature owns it. Promote it to `features/orders/` when multiple Orders subfeatures consume it.

Avoid sibling dependencies such as `create-order` importing internal code from `cancel-order`. Promote their common dependency to the Orders domain level instead.

## Services and business logic

Do not require a service for every route. Keep trivial route-specific behavior in the route handler when extraction adds no value.

Create a service/use-case function when business logic is substantial, independently testable, reused, or should remain independent from HTTP/Hono concerns.

Place domain services under the owning feature or subfeature. Do not create a global `src/services/` directory.

Keep services free of Hono `Context` when practical. Pass explicit business inputs rather than coupling domain logic to the HTTP request context.

## Validation and schemas

Keep request validation schemas close to the routes/business capability they describe:

```text
features/clients/schemas/create-client.schema.ts
```

or, for a local subfeature:

```text
features/orders/create-order/create-order.schema.ts
```

Promote schemas to the domain level only when multiple domain subfeatures reuse them. Move validation helpers to `shared/validation/` only when genuinely domain-agnostic.

Do not create a global business-schema bucket merely because the project uses Zod, Valibot, Standard Schema, or another validator.

## Middleware placement

Classify middleware by ownership:

```text
feature-only middleware
-> features/<domain>/middleware/

application-wide infrastructure middleware
-> core/middleware/

genuinely reusable domain-agnostic middleware
-> shared/middleware/
```

Use Hono's typed middleware helpers when extracting middleware so Context variables remain type-safe.

Do not place authentication middleware in `shared` merely because many routes consume it if the middleware embodies authentication-domain rules. Keep domain ownership stronger than superficial reuse.

## Context and environment types

Keep runtime bindings and application context variables deliberately scoped.

Place application-wide environment/binding types near configuration/runtime infrastructure, for example:

```text
core/config/env.ts
```

Keep feature-specific context types with the feature when possible.

Avoid broad global Context augmentation for variables that are not guaranteed to exist application-wide. Prefer typed Hono `Env`/`Variables` generics and typed middleware boundaries.

## Core

Use `core/` for global application/runtime infrastructure, not business concepts.

Typical examples:

```text
core/
├── config/
├── database/
├── errors/
├── logging/
└── middleware/
```

Examples:

```text
database client / ORM bootstrap -> core/database/
application logger              -> core/logging/
global error mapping            -> core/errors/
runtime env parsing             -> core/config/
clients repository              -> features/clients/
order calculation               -> features/orders/
```

## Database and repositories

Separate persistence infrastructure from domain-aware data access.

Put generic database initialization/client infrastructure in `core/database/`.

Put repositories that know business entities and queries in the owning domain:

```text
features/clients/repositories/clients.repository.ts
features/orders/repositories/orders.repository.ts
```

Do not centralize domain repositories under `core/database/repositories/`.

If a repository is used by several subfeatures of one domain, place it at the domain level. Cross-domain access should normally happen through an explicit domain boundary rather than by moving domain repositories to `shared`.

## Shared

Use `shared/` only for genuinely reusable, domain-agnostic application code.

Reasonable examples include generic pagination types, generic validation helpers, reusable HTTP middleware, or pure utilities with no business vocabulary.

Do not move a function to `shared` merely because it is pure or used twice. Domain knowledge determines ownership.

For example:

```text
calculate-order-total.ts -> features/orders/utils/
parse-pagination.ts      -> shared/utils/   # if truly generic
```

## Runtime-specific code

Keep Hono's multi-runtime nature explicit. Isolate code that depends specifically on Cloudflare Workers, Node.js, Bun, Deno, Lambda, or another adapter from portable domain code.

Prefer the smallest scope that owns the runtime dependency. Put application-wide runtime infrastructure under `core/` or the runtime's required project-level configuration location.

Do not scatter Cloudflare bindings, Node globals, or runtime adapter details throughout domain services when they can be passed through explicit abstractions or typed inputs.

Do not create runtime abstraction layers speculatively. Add them when the project actually targets multiple runtimes or portability materially matters.

## RPC and type inference

When Hono RPC or typed clients are used, preserve route type inference as an architectural constraint.

Prefer chained route definitions for route apps that need exported `typeof app` inference. Compose larger applications with chained `app.route()` calls when necessary to retain the complete inferred application type.

Do not restructure routes into generic controller functions if doing so degrades route/path/validation inference.

For very large RPC applications, allow domain-level route apps/types to remain separate rather than forcing one enormous inferred type when IDE/type-checker performance suffers.

## Tests

Colocate unit tests with the implementation they exercise:

```text
clients.service.ts
clients.service.test.ts

clients.repository.ts
clients.repository.test.ts
```

Keep route/integration tests with the feature or subfeature they exercise:

```text
features/clients/
├── clients.routes.ts
└── clients.routes.test.ts
```

Use Hono's `app.request()` for request/response tests where appropriate. Use `testClient()` when typed route testing is useful, while preserving the chained route definitions required for inference.

Do not create centralized `unit/` and `integration/` directories by default.

Use `src/test/` only for genuinely transversal test infrastructure such as global setup or domain-agnostic helpers.

## Test factories, builders, mocks, and fixtures

Apply the nearest-common-ancestor rule to test support artifacts:

```text
features/clients/client-list/test/
        -> features/clients/test/
        -> src/test/
```

Keep domain-aware factories/builders inside their domain even though they are test-only.

Keep a tiny helper or factory inside a single test file when only that test uses it.

Do not pre-create `factories/`, `builders/`, `fixtures/`, `mocks/`, `stubs/`, and `fakes/` directories without actual need.

Keep end-to-end/runtime-specific test support in the E2E boundary used by the project/runtime rather than coupling E2E tests to internal feature test artifacts by default.

## Placement decision algorithm

For every new or moved file, decide in this order:

1. Is it runtime/bootstrap composition? Place it at the runtime/application composition boundary (`index.ts`, `app.ts`, or runtime-required configuration).
2. Is it global infrastructure? Place it in `core/`.
3. Does exactly one subfeature own it? Keep it inside that subfeature.
4. Do multiple subfeatures of one domain use it? Promote it to the domain root/category.
5. Do multiple domains use it and is it genuinely domain-agnostic? Promote it to `shared/`.
6. Does it still contain business vocabulary or business rules? Keep it in the owning domain even if another domain has similar code.
7. Is it test support? Apply the same scope rules before considering `src/test/`.
8. Is a new directory actually necessary? If not, colocate the file without inventing taxonomy.

## Dependency direction

Prefer dependencies flowing approximately as:

```text
runtime/bootstrap
    -> app composition
        -> feature route apps
            -> domain services/repositories
                -> core infrastructure / shared primitives
```

Do not let `core` depend on business features. Do not let `shared` depend on business features. Avoid sibling subfeature dependencies.

## Creation behavior

When creating code:

- Inspect the existing repository before introducing new directories.
- Preserve established runtime conventions unless they conflict with an explicit project rule.
- Start with the smallest useful structure.
- Prefer feature route modules and `app.route()` composition for growing applications.
- Avoid controllers by default.
- Preserve Hono type inference when choosing file boundaries.
- Add service/repository/schema directories only when the feature actually needs them.
- Keep runtime-specific code out of portable domain logic where practical.

## Review behavior

When reviewing structure, flag:

- global `controllers/`, `routes/`, `services/`, or `repositories/` buckets that mix domains;
- controller extraction that weakens Hono route type inference;
- business code placed in `core`;
- domain-aware code placed in `shared`;
- sibling subfeature dependencies;
- repositories centralized away from their owning domains;
- runtime-specific APIs leaking unnecessarily throughout business services;
- Context being passed deep into domain logic without need;
- global Context augmentation for values not guaranteed globally;
- centralized unit/integration test buckets that break colocation;
- domain-specific test factories incorrectly promoted to `src/test/`;
- speculative empty taxonomy directories.

Recommend the smallest move that restores clear ownership rather than proposing a broad rewrite.

## Canonical example

```text
src/
├── index.ts
├── app.ts
├── core/
│   ├── config/
│   │   └── env.ts
│   ├── database/
│   │   └── database.ts
│   ├── errors/
│   │   └── error-handler.ts
│   ├── logging/
│   └── middleware/
│       └── request-id.middleware.ts
├── features/
│   ├── auth/
│   │   ├── auth.routes.ts
│   │   ├── auth.service.ts
│   │   ├── middleware/
│   │   │   └── require-auth.middleware.ts
│   │   └── schemas/
│   ├── clients/
│   │   ├── clients.routes.ts
│   │   ├── clients.routes.test.ts
│   │   ├── clients.service.ts
│   │   ├── clients.service.test.ts
│   │   ├── repositories/
│   │   │   └── clients.repository.ts
│   │   ├── schemas/
│   │   │   ├── create-client.schema.ts
│   │   │   └── update-client.schema.ts
│   │   ├── types/
│   │   └── test/
│   │       └── client.factory.ts
│   └── orders/
│       ├── orders.routes.ts
│       ├── repositories/
│       │   └── orders.repository.ts
│       ├── create-order/
│       │   ├── create-order.routes.ts
│       │   ├── create-order.service.ts
│       │   └── create-order.schema.ts
│       └── cancel-order/
│           ├── cancel-order.routes.ts
│           └── cancel-order.service.ts
├── shared/
│   ├── middleware/
│   ├── validation/
│   ├── types/
│   └── utils/
└── test/
    └── setup.ts
```

Treat this tree as a map of valid destinations, not a requirement to create every folder.

## Hono references

Consult `references/hono-structure-notes.md` when a placement decision involves Hono-specific route composition, controller extraction, RPC/type inference, middleware typing, Context variables, validation, or testing behavior.
