---
name: astro-project-structure
description: Enforce file and folder placement conventions for Astro projects such as landing pages, marketing sites, blogs, portfolios, and documentation-style content sites. Use when creating, moving, reviewing, or deciding where to place Astro pages, endpoints, layouts, components, page sections, UI primitives, framework islands, content collections, data modules, lib code, actions, middleware, images, SEO files, build checks, or tests. Apply type-first Astro folders with domain subfolders, nearest-common-ancestor placement, and progressive promotion.
---

# Astro Project Structure

Place every file by two questions: what kind of file is it (Astro's type-first folders), and which domain owns it (a subfolder inside that type). This skill governs placement only, not component implementation, styling, or business logic.

Verify Astro API facts (reserved paths, loaders, config imports) with the Astro Docs MCP tool `search_astro_docs` before Context7: Context7 can lag behind the current Astro major.

## Core rules

- **Reserved paths are fixed.** `src/pages/` is the only directory Astro reserves. A few files are fixed too: `src/content.config.ts`, `src/live.config.ts`, `src/actions/index.ts`, `src/middleware.ts` (or `src/middleware/index.ts`). Everything else is convention, and this skill sets it.
- **Type first, domain second.** Top-level folders under `src/` name a kind of file (`components/`, `layouts/`, `lib/`, `content/`). Inside each, a subfolder names the domain that owns the file.
- **Nearest common ancestor.** Place a file in the narrowest scope that contains all its consumers. Promote it only when real reuse appears: page frontmatter → domain subfolder → root of the type folder.
- **Ownership by domain knowledge.** A file that encodes a domain concept stays in that domain's subfolder even when another domain consumes it. A domain may import what another domain exposes, as long as no import cycle forms.
- **Domain names come from the project's vocabulary.** When the repo has a `GLOSSARY.md`, folder names use its canonical terms. Routes keep their public URLs; a folder name never forces a URL change.
- **Folders appear on demand.** Create a folder when its first file arrives; a tree of empty folders is speculative structure.

## Top-level structure

```text
project/
├── public/                 # served as is, at a fixed URL
├── scripts/                # build-time Node scripts and post-build checks
├── e2e/                    # black-box browser tests
├── src/
│   ├── pages/              # routes and endpoints only
│   ├── layouts/            # page shells and the parts only shells use
│   ├── components/
│   │   ├── ui/             # design-system primitives
│   │   ├── sections/       # generic page blocks
│   │   └── <domain>/       # domain-specific components
│   ├── content/            # collection source files
│   ├── data/               # typed singletons and site data
│   ├── lib/                # TypeScript logic: generic at the root, <domain>/ below
│   ├── actions/            # server actions (on-demand rendering)
│   ├── assets/             # images and files Astro optimizes
│   ├── styles/             # global stylesheets
│   ├── content.config.ts
│   └── middleware.ts
├── astro.config.mjs
└── tsconfig.json           # "@/*": ["./src/*"]
```

## Pages and endpoints

`src/pages/` holds routes: `.astro` pages, `.md` pages, and `.ts` endpoints (`robots.txt.ts`, `rss.xml.ts`, `[slug].md.ts`). A page is the composition point: it queries content, picks a layout, and arranges sections.

- Logic used by one page lives in that page's frontmatter or endpoint file. It moves to `lib/` when a second consumer appears.
- Components used by one page live in `components/<domain>/`, not beside the page.
- Astro excludes `_`-prefixed files from routing, which allows colocating helpers inside `pages/`. Reserve that for a deep route subtree with substantial private code (`pages/docs/_sidebar.ts`); everywhere else keep `pages/` route-only, so promoting a file never means moving it out of the router.
- Keep every non-route file out of `pages/`, tests included: any `.astro`, `.md`, or `.ts` file there becomes a route.

## Layouts

`src/layouts/` holds page shells: the components that render `<html>`, `<head>`, and the slot pages fill (`BaseLayout.astro`, `BlogPostLayout.astro`).

Parts used only by layouts sit beside them (`layouts/SiteHeader.astro`, `layouts/SiteFooter.astro`). When a page or a section also renders one, promote it to `components/`.

## Components

Three layers, from generic to specific:

| Layer | Holds | Knows about |
| --- | --- | --- |
| `components/ui/` | Primitives: `Button`, `Card`, `Badge`, `Icon` | Nothing but props |
| `components/sections/` | Page blocks: `Hero`, `FeatureGrid`, `Pricing`, `Testimonials`, `FAQ`, `CTA` | Nothing but props |
| `components/<domain>/` | Domain components: `dental/InsuranceTable.astro`, `blog/PostCard.astro` | One domain |

- A section that names a niche, a product, or a content type belongs to `components/<domain>/`. Generic means every text, image, and link arrives by props or slots.
- shadcn/ui or another design system keeps its configured path: when `components.json` exists, its alias decides where primitives live (normally `components/ui/`).
- Framework islands (`.tsx`, `.svelte`, `.vue`) follow the same layers as `.astro` files. Place by domain, never by framework: `components/react/` is a smell.
- A component used by several sibling domains and free of domain concepts promotes to `sections/` or `ui/`.

## Content and data

| Location | Holds |
| --- | --- |
| `src/content/<collection>/` | A set of entries with the same shape: one `.md`, `.mdx`, `.yaml`, or `.json` file per entry, or one file holding all entries |
| `src/content.config.ts` | Every build-time collection: loader plus Zod schema |
| `src/live.config.ts` | Live (request-time) collections |
| `src/data/` | Typed singletons and site data that are not a set: profile, navigation, pricing tiers of one product |

- A collection is a set of structurally identical entries. Data that exists once (a profile, a site settings object) is a typed TypeScript module in `src/data/`, not a one-entry collection.
- Schemas live in `content.config.ts`. When the file grows past easy reading, move each schema to `src/content/schemas/<collection>.ts` and import it.
- Cross-collection links use `reference()` in the schema. When one side is a `data/` module, validate the link at build time (for example in `getStaticPaths`) so a broken id fails the build.

### Several landings in one project

- **Same structure, different content**: one collection (`src/content/landings/dental.yaml`, `gym.yaml`) and one dynamic route (`pages/[niche].astro`) that maps each entry to sections. A new niche is a new content file.
- **Own structure**: one page per landing (`pages/dental.astro`) composing `sections/` and `components/dental/`.

## Lib

`src/lib/` holds TypeScript logic that is not a component.

```text
lib/
├── site.ts             # site-wide constants and URL helpers: paths, OG defaults, absoluteUrl()
├── dates.ts            # generic helpers
├── json-ld.ts          # generic serializer
├── dental/
│   └── structured-data.ts
└── blog/
    ├── reading-time.ts
    └── structured-data.ts
```

- Text the site displays (navigation labels, contact details) is data: it lives in `src/data/`, and `lib/` holds the logic around it.
- Split by domain, with generic helpers at the root. A helper that only understands one domain's data stays in that domain's subfolder even when a generic page calls it.
- Read the site URL from `astro:config/server` (or `astro:config/client` in browser code) instead of copying `site` from `astro.config.mjs` into a constant.
- Prefer `lib/` as the single name for logic; `utils/` and `helpers/` beside it split one concept across two folders.

## Actions, middleware, and on-demand rendering

- Actions are exported from the `server` object in `src/actions/index.ts`. Define them per domain in `src/actions/<domain>.ts` and re-export each domain object from `index.ts` (`actions.leads.submit`).
- A page whose `<form>` posts to an action must be rendered on demand (`export const prerender = false`). To keep the page prerendered, call the action from a client island instead.
- Middleware lives in `src/middleware.ts`. When it chains several handlers, use `src/middleware/index.ts` with one file per handler beside it, combined by `sequence()`.
- Server-only clients (database, email, CRM) live in `lib/<domain>/` or, when shared, in `lib/server/`.

## Assets and static files

- `src/assets/<domain>/`: images rendered through `<Image />` or `<Picture />`, so Astro optimizes them. Generic images go in `src/assets/` root.
- `public/`: files that need a fixed URL and no processing: `favicon.svg` with its `favicon.ico` and `apple-touch-icon.png` fallbacks, `og.png`, PDFs, `_headers`, verification files.

## Styles

- `src/styles/global.css`: imported once, by the base layout. Tailwind's entry `@import "tailwindcss"` lives here.
- Component and page styles stay in that file's `<style>` block. A stylesheet shared by several components of one domain sits beside them in `components/<domain>/`.

## SEO surface

Keep each SEO concern in one place so every page gets it the same way. Validate the result with the `seo-audit` skill.

| Concern | Place |
| --- | --- |
| Title, description, canonical, Open Graph, JSON-LD tag | The base layout's `<head>`, or one `components/seo/Head.astro` it renders |
| JSON-LD builders | `lib/<domain>/structured-data.ts`, generic serializer in `lib/json-ld.ts` |
| `robots.txt`, `llms.txt`, RSS, Markdown copies | Endpoints in `pages/` (`robots.txt.ts`, `[slug].md.ts`) |
| Sitemap | `@astrojs/sitemap` in `astro.config.mjs` |
| OG images | `public/` when static; an endpoint in `pages/` when generated per page |

## Build checks

Post-build checks over `dist/` (accessibility with axe or pa11y, links, heading order, title and description length) live in `scripts/` and run as part of `pnpm build`, so CI and deploy run them too. A check that fails the build enforces a rule on every change; a rule written only in a document depends on someone remembering it.

## Tests

- Unit tests sit beside the file they test: `lib/blog/reading-time.test.ts`, `components/sections/Pricing.test.ts`.
- Configure Vitest in `vitest.config.ts` with `getViteConfig()` from `astro/config`.
- Render `.astro` components with the Container API (`experimental_AstroContainer` from `astro/container`) in Vitest's `node` environment; since Astro 6 it no longer renders in `jsdom` or `happy-dom`.
- Test page and endpoint logic through the `lib/` function they call, or end to end. Keep test files out of `src/pages/`.
- Test support (factories, fixtures) follows the same scope rule: beside the test, then `lib/<domain>/test/`, then `src/test/` when genuinely cross-domain.
- End-to-end tests live in `e2e/` at the root with Playwright, independent of `src/` internals.

## Placement algorithm

For each new or moved file:

1. Is it a route or endpoint? → `src/pages/`.
2. Is it a fixed-location file? → its reserved path.
3. Does it render `<html>` and `<head>`, or only serve a layout? → `src/layouts/`.
4. Is it a component? Pick the layer: primitive → `ui/`, generic block → `sections/`, domain concept → `<domain>/`.
5. Is it content? A set of same-shaped entries → `src/content/<collection>/`; a singleton → `src/data/`.
6. Is it logic? Used by one page → that page's file; one domain → `lib/<domain>/`; generic → `lib/` root.
7. Is it an image? Optimized → `src/assets/`; fixed URL → `public/`.
8. Is it a build script or a post-build check? → `scripts/`.

Done when every file in scope has an owner and a scope that matches its current consumers.

## Review checklist

When reviewing a tree, report each of these with the file and the move that fixes it:

- non-route files inside `src/pages/` (components, helpers, tests) outside a justified `_` subtree;
- domain concepts inside `components/ui/` or `components/sections/`;
- components grouped by framework instead of by domain;
- logic used by one domain sitting at the `lib/` root, or a page-only helper promoted early;
- a one-entry collection that should be a `data/` module, or a set of same-shaped entries kept as a hand-written array;
- the site URL duplicated outside `astro.config.mjs`;
- SEO tags assembled in more than one place;
- optimizable images in `public/`;
- relative imports climbing two or more levels where the `@/` alias applies;
- empty speculative folders.

A tree that is merely asymmetric is fine: refactor only what breaks a rule.

## Canonical example

A multi-niche landing site with a blog:

```text
src/
├── pages/
│   ├── index.astro
│   ├── [niche].astro              # one route for all landings
│   ├── blog/
│   │   ├── index.astro
│   │   └── [slug].astro
│   ├── robots.txt.ts
│   └── rss.xml.ts
├── layouts/
│   ├── BaseLayout.astro
│   ├── SiteHeader.astro
│   └── SiteFooter.astro
├── components/
│   ├── ui/          Button.astro, Card.astro
│   ├── sections/    Hero.astro, Pricing.astro, FAQ.astro, CTA.astro
│   ├── landing/     LeadForm.tsx                # island shared by every landing
│   └── blog/        PostCard.astro
├── content/
│   ├── landings/    dental.yaml, gym.yaml
│   └── blog/        first-post.md
├── data/            site.ts                      # brand, navigation, contact
├── lib/
│   ├── json-ld.ts
│   ├── landing/     structured-data.ts
│   └── blog/        reading-time.ts, reading-time.test.ts
├── actions/
│   ├── index.ts
│   └── leads.ts
├── assets/
│   ├── landing/     dental-hero.jpg, gym-hero.jpg
│   └── blog/
├── styles/          global.css
└── content.config.ts
```

Treat this tree as the set of allowed scopes, not a list of folders to pre-create.
