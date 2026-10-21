---
name: nestjs-project-structure
description: Enforce project file and folder placement conventions for NestJS TypeScript applications. Use when creating, moving, reviewing, or deciding where to place NestJS modules, controllers, services, repositories, DTOs, entities, guards, strategies, decorators, pipes, validators, configuration, database infrastructure, tests, or domain-specific code. Apply feature-first organization, colocation, nearest-common-ancestor placement, progressive promotion from subfeature to domain to shared scope, and NestJS-native bootstrap and E2E conventions. This skill governs project structure and placement only, not business logic or implementation style.
---

# NestJS Project Structure

## Core philosophy

Organize by business feature/domain first and technical responsibility second.

Place code in the smallest semantic scope that owns all current consumers. Promote code only after real reuse appears:

```text
subfeature -> domain -> shared
```

Prefer domain ownership over superficial technical reuse. Do not move domain-aware code to `shared/` merely because another domain contains something similar.

Do not create speculative empty folders. Treat the canonical trees in this skill as allowed locations, not directories that must always exist.

Avoid dependencies between sibling subfeatures. If sibling subfeatures need the same artifact, promote it to their domain-level nearest common ancestor.

## Top-level structure

Prefer this baseline:

```text
project/
├── src/
│   ├── main.ts
│   ├── app.module.ts
│   ├── core/
│   ├── features/
│   ├── shared/
│   └── test/                 # only when transversal test infrastructure exists
├── test/                     # NestJS E2E boundary
├── nest-cli.json
├── tsconfig.json
└── package.json
```

Add framework/tool-specific root directories such as `prisma/` when the selected persistence tool requires them.

## Bootstrap and composition root

Keep `src/main.ts` at the root of `src/`. Treat it as the technical NestJS bootstrap entry point.

Keep `src/app.module.ts` at the root of `src/`. Treat `AppModule` as the application composition root and keep it focused primarily on assembling application modules and global composition.

Use this conceptual flow:

```text
src/main.ts
    -> AppModule
        -> global infrastructure
        -> feature modules
```

Do not place `main.ts` under `core/`, `features/`, or another domain folder by default.

## `core/`: global application infrastructure

Place global technical infrastructure in `src/core/` when it describes how the application operates rather than a business domain.

Typical examples include:

```text
core/
├── config/
├── database/
├── errors/
├── logging/
└── http/
```

Examples of appropriate ownership:

```text
PrismaService           -> core/database/
Global exception filter -> core/errors/
Application logger      -> core/logging/
Environment validation  -> core/config/
```

Do not place domain repositories, domain DTOs, or business rules in `core/`.

## `features/`: business domains

Place business capabilities under `src/features/<domain>/`.

Prefer:

```text
features/
├── auth/
├── users/
├── clients/
└── orders/
```

Avoid organizing a growing application globally by technical type:

```text
src/controllers/
src/services/
src/repositories/
src/dto/
```

Keep controllers, services, DTOs, repositories, entities, validators, and other artifacts with the domain that owns them.

For a small feature, keep the structure flat:

```text
features/clients/
├── clients.module.ts
├── clients.controller.ts
├── clients.service.ts
└── client.entity.ts
```

Create responsibility folders only when they improve clarity or contain enough related artifacts:

```text
features/users/
├── users.module.ts
├── users.controller.ts
├── users.service.ts
├── dto/
├── entities/
├── repositories/
├── validators/
└── utils/
```

Do not create these folders preemptively.

## Subfeatures in large domains

When a domain becomes large, split it by business capability/use case before creating broader technical buckets.

Example:

```text
features/orders/
├── orders.module.ts
├── create-order/
│   ├── create-order.controller.ts
│   ├── create-order.service.ts
│   └── create-order.dto.ts
├── cancel-order/
│   ├── cancel-order.controller.ts
│   └── cancel-order.service.ts
├── order-history/
│   ├── order-history.controller.ts
│   └── order-history.service.ts
├── repositories/
│   └── orders.repository.ts
└── entities/
    └── order.entity.ts
```

Keep an artifact inside a subfeature when only that subfeature uses it. Promote it to the domain root or an appropriate domain-level category when multiple sibling subfeatures need it.

## Modules

Keep each feature module with the feature it composes:

```text
features/clients/clients.module.ts
features/orders/orders.module.ts
```

Use nested modules only when the domain is sufficiently large or independently composable. Do not create one Nest module per folder mechanically.

Keep infrastructure modules with their infrastructure owner, for example:

```text
core/database/database.module.ts
core/logging/logging.module.ts
```

## Controllers and services

Keep controllers and services with the feature or subfeature whose use cases they expose or orchestrate.

Do not create global `controllers/` or `services/` directories for domain code.

When a service contains domain-specific behavior, keep it in the owning domain even if another feature has a similarly named service.

## DTOs

Place DTOs at the smallest scope containing their consumers.

Examples:

```text
features/clients/dto/create-client.dto.ts
features/clients/dto/update-client.dto.ts
features/orders/create-order/create-order.dto.ts
```

Keep subfeature-only DTOs local. Promote DTOs to domain-level `dto/` only when multiple parts of the domain share them.

Do not move business DTOs to `shared/` merely because they are used by several endpoints in one domain.

## Entities and domain types

Keep entities and domain-aware types inside their owning feature.

Examples:

```text
features/clients/entities/client.entity.ts
features/orders/types/order-status.ts
```

Avoid a catch-all global `src/types/` for business concepts.

Promote a type to `shared/types/` only when it is genuinely domain-agnostic and used across multiple domains.

## Repositories and persistence

Separate persistence infrastructure from domain data access ownership.

Place generic database infrastructure in `core/database/`:

```text
core/database/prisma/
├── prisma.module.ts
└── prisma.service.ts
```

Place domain repositories in their feature:

```text
features/clients/repositories/clients.repository.ts
features/orders/repositories/orders.repository.ts
```

Do not centralize domain repositories under `core/database/repositories/`.

If Prisma is used, keep Prisma's tool-owned schema and migrations at the conventional project root unless project requirements dictate otherwise:

```text
prisma/
├── schema.prisma
└── migrations/
```

Apply the same ownership distinction to TypeORM, Drizzle, MikroORM, or other persistence tools: infrastructure belongs to `core`; domain queries/repositories belong to the owning feature.

## Authentication and authorization

Treat authentication as a business/application feature by default:

```text
features/auth/
├── auth.module.ts
├── auth.controller.ts
├── auth.service.ts
├── dto/
├── guards/
├── strategies/
├── decorators/
└── types/
```

Keep auth-specific guards, strategies, decorators, and types under `features/auth/` when they encode authentication or authorization semantics.

Place only genuinely global technical configuration in `core/`, such as environment/configuration plumbing used to configure JWT or external identity providers.

Do not move auth artifacts to `shared/` merely because multiple business features rely on authentication.

## Guards, interceptors, pipes, filters, decorators, and validators

Determine placement by semantic ownership, not NestJS artifact type.

Use these scopes:

1. Subfeature-specific -> keep in the subfeature.
2. Domain-specific -> keep under the owning feature.
3. Global application infrastructure -> place in `core/`.
4. Cross-domain and domain-agnostic reusable artifact -> place in `shared/`.

Examples:

```text
features/auth/guards/jwt-auth.guard.ts
features/clients/validators/unique-client-code.validator.ts
core/errors/global-exception.filter.ts
shared/pipes/parse-date.pipe.ts
```

Do not create a global `guards/`, `interceptors/`, or `decorators/` directory merely because NestJS defines those artifact categories.

## `shared/`: domain-agnostic reuse

Use `src/shared/` only for genuinely reusable code that does not belong to a business domain or global application infrastructure.

Possible categories include:

```text
shared/
├── decorators/
├── pipes/
├── validators/
├── types/
└── utils/
```

Do not use `shared/`, `common/`, `helpers/`, or `utils/` as dumping grounds.

A pure function is not automatically shared. If it knows about a business concept, keep it in that domain:

```text
calculate-order-total.ts -> features/orders/utils/
```

## Dependency direction

Prefer this conceptual dependency direction:

```text
subfeature
    -> domain-level artifacts
        -> shared domain-agnostic building blocks
        -> core technical infrastructure when required
```

Features may consume global infrastructure through well-defined modules/providers. Avoid feature-to-feature coupling when a clearer domain boundary or explicit shared abstraction is possible.

Do not promote code solely to make an import path shorter.

## Testing

### Unit and focused component/provider tests

Colocate tests beside the implementation they exercise:

```text
clients.service.ts
clients.service.spec.ts

clients.controller.ts
clients.controller.spec.ts

repositories/
├── clients.repository.ts
└── clients.repository.spec.ts
```

Do not create centralized `unit/` directories by default.

### Integration tests

Keep integration tests with the feature or subfeature whose collaboration they exercise. Use an explicit naming convention such as `*.integration.spec.ts` only when it materially improves clarity or test commands.

Do not create a global `integration/` folder by default.

### Test support artifacts

Place factories, builders, mocks, fixtures, stubs, fakes, and helpers at their nearest common ancestor.

Promotion path:

```text
features/<domain>/<subfeature>/test/
                -> features/<domain>/test/
                    -> src/test/
```

Examples:

```text
features/clients/client-import/test/client-import.factory.ts
features/clients/test/client.factory.ts
features/clients/test/client.builder.ts
src/test/setup.ts
src/test/helpers/
```

Keep domain-aware factories and builders inside their domain. Do not move them to `src/test/` simply because they are test-only.

Keep a tiny helper or factory inside a single spec file when no reuse justifies a separate file.

Use `src/test/` only for genuinely transversal, domain-agnostic test infrastructure.

### E2E tests

Preserve NestJS's conventional root `test/` boundary for black-box E2E tests:

```text
test/
├── app.e2e-spec.ts
├── auth/
│   └── login.e2e-spec.ts
├── clients/
│   └── clients.e2e-spec.ts
├── fixtures/
└── support/
```

Keep E2E-specific factories, fixtures, helpers, and support code inside the root `test/` boundary when they exist only for E2E.

Do not make E2E tests depend by default on internal `src/features/**/test/` artifacts.

## Placement decision algorithm

For every new or moved file, decide in this order:

1. Is it the NestJS bootstrap entry point? -> `src/main.ts`.
2. Is it the root application composition module? -> `src/app.module.ts`.
3. Is it global technical infrastructure? -> `src/core/`.
4. Does it belong to exactly one business subfeature/use case? -> keep it inside that subfeature.
5. Is it used by multiple subfeatures of the same domain? -> promote it to the domain-level nearest common ancestor.
6. Is it still domain-aware? -> keep it in the owning domain even if another domain has similar code.
7. Is it used across multiple domains and genuinely domain-agnostic? -> `src/shared/`.
8. Is it a unit/focused test? -> colocate beside the implementation.
9. Is it domain-aware test support? -> keep it under that subfeature/domain `test/` scope.
10. Is it genuinely transversal test infrastructure? -> `src/test/`.
11. Is it black-box E2E code? -> root `test/`.

When uncertain, choose the narrower semantic scope. Promote later when actual reuse proves a broader scope.

## Creation behavior

When creating files or scaffolding:

- Preserve NestJS naming conventions such as `*.module.ts`, `*.controller.ts`, `*.service.ts`, and `*.spec.ts`.
- Prefer feature/domain-first placement over global technical-type folders.
- Keep small features flat until additional grouping improves comprehension.
- Create only directories needed by current code.
- Keep domain ownership explicit.
- Avoid speculative abstractions and speculative shared folders.
- Preserve tool-owned conventional directories such as root `prisma/` or root NestJS `test/` when applicable.

## Review behavior

When reviewing an existing NestJS structure, flag:

- Global `controllers/`, `services/`, `repositories/`, or `dto/` buckets containing unrelated domains.
- Domain code incorrectly placed in `core/`.
- Domain-aware code incorrectly promoted to `shared/`.
- Sibling subfeatures importing private/local artifacts from one another instead of promoting shared domain code.
- Authentication-specific code incorrectly treated as generic shared infrastructure.
- Domain repositories centralized under database infrastructure.
- Empty/speculative category folders.
- Centralized unit/integration test buckets that break colocation.
- Domain-specific factories/builders/mocks incorrectly placed in `src/test/`.
- E2E support unnecessarily coupled to internal feature test artifacts.
- `main.ts` moved away from `src/` without a project-specific reason.

Prefer incremental moves toward the nearest correct owner rather than large cosmetic reorganizations with no semantic benefit.

## Canonical example

```text
project/
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── src/
│   ├── main.ts
│   ├── app.module.ts
│   ├── core/
│   │   ├── config/
│   │   │   └── env.validation.ts
│   │   ├── database/
│   │   │   └── prisma/
│   │   │       ├── prisma.module.ts
│   │   │       └── prisma.service.ts
│   │   ├── errors/
│   │   │   └── global-exception.filter.ts
│   │   └── logging/
│   │       └── logging.module.ts
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth.module.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── guards/
│   │   │   └── strategies/
│   │   ├── clients/
│   │   │   ├── clients.module.ts
│   │   │   ├── clients.controller.ts
│   │   │   ├── clients.controller.spec.ts
│   │   │   ├── clients.service.ts
│   │   │   ├── clients.service.spec.ts
│   │   │   ├── dto/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   │   ├── clients.repository.ts
│   │   │   │   └── clients.repository.spec.ts
│   │   │   └── test/
│   │   │       └── client.factory.ts
│   │   └── orders/
│   │       ├── orders.module.ts
│   │       ├── create-order/
│   │       ├── cancel-order/
│   │       ├── repositories/
│   │       └── entities/
│   ├── shared/
│   │   ├── pipes/
│   │   ├── validators/
│   │   ├── types/
│   │   └── utils/
│   └── test/
│       └── setup.ts
├── test/
│   ├── auth/
│   ├── clients/
│   ├── fixtures/
│   └── support/
├── nest-cli.json
├── tsconfig.json
└── package.json
```

Adapt this tree to the project. Do not create every illustrated directory unless current code needs it.
