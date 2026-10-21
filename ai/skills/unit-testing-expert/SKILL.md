---
name: unit-testing-expert
description: Create, review, or refactor unit/integration/component/API tests in Vitest or Jest with Testing Library. Use when writing tests, fixing flaky tests, or auditing test quality against strict rules that prioritize simplicity, AAA structure, minimal assertions, and user-facing behavior.
---

# Unit Testing Expert

## Overview
Use this skill to implement or review tests that must follow the repository’s strict unit-testing rules. The rules apply to unit, integration, component, microservice, and API tests using Vitest/Jest + Testing Library.

## Workflow
1. **Confirm scope**: If a test spans multiple processes or does not mock backend/external calls, treat it as E2E and ask for the E2E rules instead of applying this skill.
2. **Load rules**: Read `references/UNIT_TESTING_RULES.MD` before writing or reviewing tests.
3. **Write tests**:
   - Enforce AAA (Arrange/Act/Assert) with clear phase separation.
   - Keep tests flat: no loops, conditionals, try/catch, comments, or console logs.
   - Use 1–3 assertions max, and ensure the “smoking gun” data appears in Arrange before Assert.
   - Use Testing Library user-facing queries (role/label/name); avoid test IDs and structural selectors.
4. **Review feedback**: When you find issues, explicitly cite the violated rule number(s) from the rules file.

## Implementation Notes
- Prefer domain data via factories; avoid dummy values and `any` types.
- Mock only external collaborators; avoid mocking internal code.
- Keep test setup local to the test or `beforeEach`—no hidden global setup.
- Favor complete comparisons (`toEqual`, `toMatchObject`) over redundant checks.

## Resources
- `references/UNIT_TESTING_RULES.MD`: Mandatory rules and examples to follow.
