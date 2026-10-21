---
name: angular-project-structure
description: Enforce a feature-first Angular project file and folder structure based on feature/domain colocation with ui, data-access, and utils boundaries. Use when creating, placing, moving, or reviewing Angular files, components, services, stores, models, pipes, directives, helpers, routes, or folders, and when deciding whether code belongs to a subfeature, its parent domain, core, or shared.
---

# Angular Project Structure

Apply these rules whenever deciding where an Angular project element belongs. This skill governs **project structure and placement only**. Do not impose implementation patterns for Signals, forms, state libraries, HTTP clients, testing, or component internals unless another instruction requires them.

## Primary principle

Organize by **business domain / feature first**, then by responsibility.

Prefer:

```text
features/
  clients/
    client-list/
    client-detail/
```

Do not organize application features primarily into global technical buckets such as:

```text
components/
services/
models/
pipes/
```

Keep related code colocated with the smallest feature/domain that owns it.

## Canonical top-level structure

Use this conceptual structure:

```text
src/
└── app/
    ├── core/
    ├── features/
    └── shared/
```

Keep application bootstrap files such as `app.component.*`, `app.config.ts`, and `app.routes.ts` directly under `app/` when appropriate.

### `core/`

Place application-wide infrastructure in `core/` when it is not owned by a business feature and is conceptually global to the application.

Typical examples:
- authentication infrastructure
- application configuration
- global HTTP infrastructure
- global guards/interceptors
- application shell/layout infrastructure

Do not use `core/` as a generic shared-code folder.

### `features/`

Create one folder per business domain or major application area.

Example:

```text
features/
├── clients/
├── orders/
└── invoices/
```

Inside a domain, represent routed screens or cohesive subfeatures as child folders when the domain contains multiple screens/capabilities.

Example:

```text
clients/
├── clients.routes.ts
├── client-list/
└── client-detail/
```

### `shared/`

Place code in `shared/` only when it is genuinely reusable across multiple business domains and is not coupled to domain-specific concepts.

Do not move code to `shared/` merely because it *could* be reused someday.

## Responsibility folders

Within a domain or subfeature, use these folders only when needed:

### `ui/`

Place presentational UI elements here, including feature-specific dumb/presentational components and, when appropriate, UI-oriented directives or pipes.

Examples:

```text
client-list/
└── ui/
    ├── client-table/
    └── client-filters/
```

### `data-access/`

Place data-access and state-related elements owned by that scope here.

Examples include API services, feature stores, domain models used by the data layer, mappers, and similar data-facing artifacts.

The location still follows the ownership rule: a service used only by `client-list` stays under `client-list/data-access/`; one shared by multiple Clients subfeatures moves to `clients/data-access/`.

### `utils/`

Place pure helpers, utilities, validators, calculations, transformations, and similar supporting logic here when they belong to that scope.

## Nearest common ancestor rule

Place an element in the **smallest scope that contains all of its actual consumers**.

Apply this rule consistently to `ui`, `data-access`, and `utils`.

Example progression:

```text
client-list/ui/
        ↓ also needed by client-detail
clients/ui/
        ↓ genuinely needed by another domain and domain-agnostic
shared/ui/
```

If only `client-list` uses `ClientTableComponent`:

```text
features/clients/client-list/ui/client-table/
```

If both `client-list` and `client-detail` use `ClientAvatarComponent`:

```text
features/clients/ui/client-avatar/
```

Do **not** make one sibling subfeature depend on another:

```text
client-detail/ -> client-list/ui/...   # avoid
client-list/   -> client-detail/ui/... # avoid
```

Promote the shared element to their parent domain instead.

## Domain ownership beats superficial reuse

Do not promote domain-specific code to global `shared/` simply because another domain has something visually or technically similar.

For example, keep this in Clients if it understands `ClientStatus` or client-specific business semantics:

```text
features/clients/ui/client-status-badge/
```

An Orders status badge may remain separate:

```text
features/orders/ui/order-status-badge/
```

Promote an element to `shared/` only when its API and behavior are genuinely domain-agnostic, such as a generic pagination control, confirmation dialog, search input, or empty state.

## Promotion rule

Start code as locally as practical and promote it only after real reuse appears.

Use this sequence:

```text
subfeature/{ui,data-access,utils}
        ↓
domain/{ui,data-access,utils}
        ↓
shared/{ui,data-access,utils}
```

Promotion to `shared/` additionally requires that the code no longer depend on a specific business domain.

## Do not create speculative folders

Do not create `ui/`, `data-access/`, or `utils/` merely to satisfy a template.

Create a responsibility folder only when at least one element belongs there.

A valid small feature can be:

```text
client-list/
├── client-list.component.ts
├── client-list.component.html
└── ui/
    └── client-table/
```

Do not add empty `data-access/` or `utils/` folders.

## Routed/smart feature placement

Treat the routed/smart component as the feature entry point. When a subfeature has one primary routed/smart component, keep it at the root of that subfeature instead of adding a redundant `feature/` directory.

Prefer:

```text
client-detail/
├── client-detail.component.ts
├── client-detail.component.html
├── ui/
└── data-access/
```

Avoid unnecessary nesting such as:

```text
client-detail/
└── feature/
    └── client-detail.component.ts
```

Use additional feature-level organization only when the scope genuinely contains multiple smart/routed entry points and the added level improves clarity.

## Placement decision procedure

When creating or moving any element, decide in this order:

1. Identify the business domain that owns the element.
2. Identify all **current** consumers; ignore hypothetical future reuse.
3. Find their nearest common feature/domain scope.
4. Classify the element as `ui`, `data-access`, `utils`, routed/feature entry point, or application infrastructure.
5. Place it at that scope under the appropriate responsibility folder.
6. If multiple business domains consume it, verify it is genuinely domain-agnostic before moving it to `shared/`.
7. If it is global application infrastructure rather than reusable business/UI code, place it in `core/` instead of `shared/`.
8. Do not create empty supporting folders.

## Reference example

Use this as a structural reference, not as a requirement to create every folder:

```text
src/app/
├── app.component.ts
├── app.config.ts
├── app.routes.ts
│
├── core/
│   ├── auth/
│   ├── http/
│   ├── config/
│   └── layout/
│
├── features/
│   ├── clients/
│   │   ├── clients.routes.ts
│   │   ├── ui/
│   │   │   └── client-avatar/
│   │   ├── data-access/
│   │   │   └── clients-api.service.ts
│   │   ├── utils/
│   │   │   └── format-client-name.ts
│   │   ├── client-list/
│   │   │   ├── client-list.component.ts
│   │   │   ├── ui/
│   │   │   │   └── client-table/
│   │   │   ├── data-access/
│   │   │   │   └── client-list.store.ts
│   │   │   └── utils/
│   │   │       └── client-list-filters.ts
│   │   └── client-detail/
│   │       ├── client-detail.component.ts
│   │       ├── ui/
│   │       │   └── client-info/
│   │       └── data-access/
│   │           └── client-detail.store.ts
│   │
│   └── orders/
│       ├── orders.routes.ts
│       ├── data-access/
│       ├── ui/
│       ├── order-list/
│       └── order-detail/
│
└── shared/
    ├── ui/
    │   ├── pagination/
    │   ├── search-input/
    │   ├── confirmation-dialog/
    │   └── empty-state/
    ├── directives/
    ├── pipes/
    └── utils/
```

## Review behavior

When reviewing a proposed structure:
- Flag elements placed too globally.
- Flag sibling-feature dependencies.
- Flag domain-specific elements incorrectly placed in `shared/`.
- Flag application infrastructure incorrectly placed in `shared/` instead of `core/`.
- Flag technical top-level buckets that destroy feature colocation.
- Flag empty/speculative responsibility folders.
- Recommend the nearest valid location and briefly state why.

When there is insufficient information to determine ownership, ask which features currently consume the element rather than guessing.
