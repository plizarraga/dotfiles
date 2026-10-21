---
name: react-vite-shadcn-project-structure
description: Enforce project file and folder placement conventions for Vite + React + TypeScript applications using shadcn/ui. Use when creating, moving, reviewing, or deciding where to place pages, components, hooks, API/data-access code, types, utilities, layouts, shadcn primitives, shared code, or domain-specific code. Apply feature-first organization, colocation, nearest-common-ancestor placement, and progressive promotion from subfeature to domain to shared scope. This skill governs project structure and placement only, not React implementation patterns or business logic.
---

# React + Vite + shadcn Project Structure

Apply these rules whenever creating or placing files in a Vite + React + TypeScript + shadcn/ui project.

## Core philosophy

Organize by domain/feature first and responsibility second.

Always place code in the smallest scope that contains all of its consumers. Promote code only after real reuse appears.

Use this progression:

```text
subfeature -> domain -> shared
```

Do not create folders speculatively. Create `components/`, `hooks/`, `api/`, `types/`, `utils/`, or `layout/` only when the feature actually needs them.

## Top-level structure

Use these responsibilities:

```text
src/
├── app/          # application composition, router and providers
├── components/
│   └── ui/       # shadcn/ui and design-system primitives
├── core/         # global application infrastructure
├── features/     # business domains and their subfeatures
├── shared/       # domain-agnostic reusable application code
├── assets/       # imported static assets when needed
├── styles/       # global styles when needed
└── main.tsx      # Vite/React technical entry point
```

Do not create a generic global `src/components/` bucket for application components. Reserve `src/components/ui/` for shadcn/design-system primitives unless the existing project configuration requires otherwise.

## shadcn/ui

Respect the component alias/path configured by shadcn, normally:

```text
src/components/ui/
```

Place shadcn primitives such as `button.tsx`, `dialog.tsx`, `input.tsx`, `table.tsx`, and `sidebar.tsx` there.

Do not move shadcn primitives into `shared/components/` merely because they are reusable.

Treat `components/ui` as the design-system primitive layer, not as a feature or business-domain layer.

## application entry point

Keep the Vite/React technical entry point at `src/main.tsx`. Do not place `main.tsx` inside `src/app/` by default.

Treat `main.tsx` as bootstrap code that mounts the React application and delegates application composition to `src/app/`. Keep it minimal.

Use this boundary:

```text
index.html
    -> src/main.tsx
        -> src/app/App.tsx
            -> providers/router
                -> features
```

Only move the entry point when an explicit project or build-tool requirement makes another location necessary.

## app

Place application composition concerns in `src/app/`:

```text
app/
├── App.tsx
├── router/
├── providers/
└── config/       # app composition config when appropriate
```

Keep route/page business implementations inside their features rather than turning `app/` into a feature bucket.

## core

Place global infrastructure and application-shell concerns in `src/core/`.

Typical categories include:

```text
core/
├── auth/
├── http/
├── config/
└── layout/
```

Place global application layouts in `core/layout/`, for example:

```text
core/layout/
├── AppLayout.tsx
├── AuthLayout.tsx
├── Header.tsx
├── Sidebar.tsx
└── Footer.tsx
```

A shadcn `sidebar.tsx` primitive remains in `components/ui/`; an application-specific `Sidebar.tsx` that composes it belongs in `core/layout/` when it forms part of the global application shell.

Do not place domain-specific layouts in `core`.

## features

Represent each business domain under `src/features/<domain>/`.

Example:

```text
features/
└── clients/
    ├── api/
    ├── hooks/
    ├── components/
    ├── types/
    ├── utils/
    ├── client-list/
    └── client-detail/
```

Treat `clients/` as the domain boundary. Code that knows about Clients should normally remain somewhere under `features/clients/`.

## subfeatures and pages

Represent routed screens or cohesive use cases as subfeatures when useful:

```text
features/clients/
├── client-list/
│   ├── ClientListPage.tsx
│   ├── components/
│   ├── hooks/
│   ├── types/
│   └── utils/
└── client-detail/
    ├── ClientDetailPage.tsx
    ├── components/
    ├── hooks/
    ├── types/
    └── utils/
```

Place the routed/container page at the root of its subfeature rather than creating an unnecessary `pages/` or `feature/` folder inside that subfeature.

Do not require every subfeature to contain every category.

## components placement

Apply nearest-common-ancestor placement.

If a component is used only by `client-list`:

```text
features/clients/client-list/components/ClientTable.tsx
```

If it is used by `client-list` and `client-detail` and remains Client-specific:

```text
features/clients/components/ClientAvatar.tsx
```

If it is genuinely domain-agnostic and reused across multiple domains:

```text
shared/components/Avatar.tsx
```

Do not equate a presentational component with a shared component. A presentational `ClientStatusBadge` remains in the Clients domain if it represents Client-specific concepts.

## hooks placement

Apply the same scope rule:

```text
features/clients/client-list/hooks/   # only client-list
features/clients/hooks/               # multiple Clients subfeatures
shared/hooks/                         # domain-agnostic across domains
```

Keep application infrastructure hooks in the relevant `core/` concern when they belong to infrastructure rather than business features.

## API and data-access placement

Place domain API/data-access code under the owning domain:

```text
features/clients/api/
├── clients.api.ts
└── clients.queries.ts
```

Keep API code local to a subfeature only when it is truly exclusive to that subfeature.

Do not promote `/clients` API knowledge to `shared/api/` merely because several Clients screens use it. Shared usage inside one domain means domain-level placement.

Place generic HTTP infrastructure in:

```text
core/http/
```

## types placement

Place types according to ownership and consumer scope:

```text
features/clients/client-list/types/  # list-specific types
features/clients/types/              # Client domain types
shared/types/                        # domain-agnostic cross-domain types
```

Avoid a global catch-all `src/types/` when ownership can be expressed through colocation.

## utils placement

Apply the same promotion rule:

```text
features/clients/client-list/utils/
        ↓ reused by Clients subfeatures
features/clients/utils/
        ↓ genuinely domain-agnostic and reused across domains
shared/utils/
```

Do not move a utility to `shared` solely because it is a pure function. Domain knowledge determines ownership.

## layouts by scope

Choose layout location by scope:

```text
Design-system primitive       -> components/ui/
Global application shell      -> core/layout/
Domain-specific layout        -> features/<domain>/layout/
Subfeature-only composition   -> features/<domain>/<subfeature>/
```

## shared

Reserve `src/shared/` for reusable, domain-agnostic application building blocks:

```text
shared/
├── components/
├── hooks/
├── utils/
└── types/
```

Examples include a generic `DataTable`, `ErrorState`, `PageHeader`, `useDebounce`, or pagination type when they truly have no business-domain dependency.

Do not use `shared` as a dumping ground.

## Dependency direction

Prefer dependencies flowing from specific to generic:

```text
Page/Subfeature
    -> Domain components/hooks/api
        -> Shared application building blocks
            -> shadcn/design-system primitives
```

Prevent sibling subfeatures from importing implementation details from one another. If both need the same element, promote that element to their nearest common domain ancestor.

Example: do not make `client-detail` import `client-list/components/ClientAvatar.tsx`; move the shared Client-specific component to `features/clients/components/`.

## Placement decision algorithm

For every new element, determine its semantic owner before creating the file.

1. If it is a shadcn/design-system primitive, place it in the configured `components/ui/` path.
2. If it is global application infrastructure or application shell, place it in `core/`.
3. If only one subfeature owns/uses it, colocate it under that subfeature and appropriate category.
4. If multiple subfeatures of the same domain use it, promote it to the domain-level category.
5. If multiple domains use it and it is genuinely domain-agnostic, promote it to `shared/`.
6. If it still contains domain concepts, keep it in its owning domain even when another domain has something visually similar.

## Promotion examples

Component:

```text
features/clients/client-list/components/ClientAvatar.tsx
                         ↓
features/clients/components/ClientAvatar.tsx
```

Promote further only if the abstraction becomes truly generic:

```text
features/clients/components/ClientAvatar.tsx
                         ↓ refactor into generic abstraction
shared/components/Avatar.tsx
```

Hook:

```text
client-list/hooks/useClientFilters.ts
            ↓ reused across Clients
clients/hooks/useClientFilters.ts
```

Do not promote to `shared/hooks` while it still understands Client-specific filtering.

## Creation behavior

When asked to create an element:

1. Identify its domain and consumers from the request and existing project.
2. Inspect existing structure when available; preserve compatible established conventions, especially the shadcn alias/path.
3. Choose the narrowest correct scope.
4. Create only the directories required for the requested element.
5. Avoid introducing new global buckets when an existing domain boundary is sufficient.
6. Explain the placement briefly when the user asks for architectural reasoning.

## Review behavior

When reviewing an existing tree, flag:

- business/domain components inside `components/ui`;
- shadcn primitives moved into feature folders without a project-specific reason;
- domain-specific code in `shared`;
- feature code placed globally despite having one clear owner;
- sibling subfeatures importing one another's internal code;
- global layouts mixed with design-system primitives;
- generic `components`, `hooks`, `types`, or `utils` dumping grounds;
- speculative empty folders;
- `main.tsx` placed inside `app/` without an explicit project/build requirement;
- duplicated elements that should be promoted to a nearest common ancestor;
- centralized unit/integration test buckets that break colocation;
- domain-specific factories/builders/mocks incorrectly placed in `src/test/`;
- E2E support coupled unnecessarily to internal feature test artifacts.

Do not require a refactor solely to make the tree visually symmetric.

## Canonical example

```text
src/
├── main.tsx                    # Vite/React technical entry point
├── app/
│   ├── App.tsx
│   ├── router/
│   └── providers/
├── components/
│   └── ui/                     # shadcn/design-system primitives
├── core/
│   ├── auth/
│   ├── http/
│   ├── config/
│   └── layout/                 # global application shell
├── test/                       # cross-domain test infrastructure only
│   ├── setup.ts
│   ├── render.tsx
│   └── mocks/
├── features/
│   ├── clients/
│   │   ├── api/
│   │   ├── hooks/
│   │   ├── components/
│   │   ├── types/
│   │   ├── utils/
│   │   ├── test/              # Client-domain test support
│   │   │   └── client.factory.ts
│   │   ├── client-list/
│   │   │   ├── ClientListPage.tsx
│   │   │   ├── ClientListPage.test.tsx
│   │   │   └── components/
│   │   └── client-detail/
│   │       ├── ClientDetailPage.tsx
│   │       └── components/
│   └── orders/
└── shared/
    ├── components/
    ├── hooks/
    ├── utils/
    └── types/

e2e/                          # application-level black-box tests
├── auth/
├── clients/
├── fixtures/
└── support/
```

Treat this tree as a set of allowed scopes, not a requirement to pre-create every directory.

## Testing placement

Apply the same colocation and nearest-common-ancestor rules to test code.

Place unit and component tests next to the implementation they test:

```text
ClientTable.tsx
ClientTable.test.tsx

useClientFilters.ts
useClientFilters.test.ts
```

Place integration tests with the feature or subfeature whose behavior they integrate. Do not create centralized `unit/` or `integration/` directories by default. Use naming such as `*.integration.test.tsx` only when distinguishing integration tests materially improves clarity.

Keep end-to-end tests outside `src/` because they exercise application-level user flows as a black box:

```text
e2e/
├── auth/
│   └── login.spec.ts
├── clients/
│   ├── client-list.spec.ts
│   └── client-detail.spec.ts
├── fixtures/
└── support/
```

Do not use `__tests__/` as the default organizational pattern. Prefer direct colocation unless an established project convention requires otherwise.

## Test support artifacts

Treat factories, builders, mocks, fixtures, stubs, fakes, and test helpers as scoped code. Place each artifact in the smallest scope containing all tests that consume it.

Use this promotion path:

```text
features/<domain>/<subfeature>/test/
                ↓ reused by domain subfeatures
features/<domain>/test/
                ↓ genuinely cross-domain test infrastructure
src/test/
```

Examples:

```text
features/clients/client-list/test/client-list.factory.ts  # client-list only
features/clients/test/client.factory.ts                    # shared across Clients tests
features/clients/test/client.builder.ts                    # Client-domain builder
src/test/render.tsx                                        # global renderWithProviders helper
src/test/setup.ts                                          # global Vitest/test setup
src/test/mocks/server.ts                                   # global MSW server
```

If a factory or builder is needed by only one test and is small, keep it in the test file rather than creating a new `test/` directory.

Do not move `ClientFactory`, `ClientBuilder`, or other domain-aware test data generators to `src/test/` merely because they are test utilities. Domain ownership still applies to test code.

Use `src/test/` only for genuinely transversal test infrastructure and domain-agnostic support. Do not turn it into a dumping ground for every factory, mock, fixture, or helper.

Do not pre-create `test/`, `factories/`, `builders/`, `mocks/`, `fixtures/`, `stubs/`, `fakes/`, or `helpers/` directories. Create them only when needed.

Keep E2E support inside the E2E boundary:

```text
e2e/
├── factories/
├── fixtures/
├── helpers/
└── support/
```

Do not make E2E tests depend by default on internal factories under `src/features/**/test/`. Keep E2E setup and data generation independent when practical so E2E tests continue to exercise the application as an external consumer.

## Testing decision algorithm

For every test or test-support artifact:

1. If it is a unit/component test, colocate it with its implementation.
2. If it integrates a feature/subfeature, colocate it with that feature/subfeature.
3. If a factory, builder, mock, fixture, or helper is used only by one subfeature, place it in that subfeature's `test/` scope or directly in the test when trivial.
4. If multiple subfeatures of one domain use it, promote it to `features/<domain>/test/`.
5. If it is genuinely domain-agnostic and used across domains, promote it to `src/test/`.
6. If it supports E2E tests, keep it under `/e2e/`.
7. Promote only after real reuse appears; never promote merely because an artifact might be reusable later.
