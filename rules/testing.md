---
description: Test runner, test placement, and what a test is allowed to assert
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.spec.ts"
  - "**/*.spec.tsx"
  - "**/vitest.config.*"
  - "**/vitest.setup.*"
  - "**/vitest.workspace.*"
  - "**/test/**"
  - "**/tests/**"
  - "**/__tests__/**"
  - "**/e2e/**"
  - "**/playwright.config.*"
---

# Testing

## Runner

- Vitest, always. Never Jest.
- Use `vi.fn`, `vi.spyOn`, `vi.mock`, `vi.useFakeTimers`. Never `jest.fn`,
  `jest.mock`, or any other `jest.*` API.
- Do not add `jest`, `ts-jest`, `babel-jest`, `jest-environment-jsdom`, or
  `@types/jest` to a project. If you find them alongside Vitest, say so rather
  than quietly using both.
- Import `describe`, `it`, `expect`, `vi`, `beforeEach` explicitly from
  `vitest`. Do not rely on globals.
- Use `it`, not `test`.

## Placement and naming

- Colocate the test next to the file it tests: `parseUser.ts` and
  `parseUser.test.ts` in the same directory. No top-level `__tests__`, `test/`,
  or `tests/` mirror tree for unit tests.
- End-to-end and integration suites that span the whole app may live in a
  top-level `e2e/` directory, since they belong to no single source file.
- Name the test after the observable behaviour, not the function:
  `it('returns null when the session has expired')`, not `it('getSession')`.

## What to assert

- Test behaviour through the public surface. If a function is not exported, test
  it through the exported thing that uses it. Do not export something purely to
  make it testable.
- Assert on explicit expected values. No snapshot tests, no `toMatchSnapshot`,
  no `toMatchInlineSnapshot`. Snapshots rot and get regenerated without anyone
  reading the diff.
- Prefer `toEqual` with a literal object over a chain of single-field
  assertions.
- One behaviour per `it`. If the name needs "and", split it.
- No conditionals or loops in a test body. A test that branches is two tests.
- Do not assert on call counts of your own internal functions. Assert on the
  result or the effect a caller can observe.

## Mocking

- Prefer the real implementation. Reach for an in-memory fake before a mock.
- `vi.mock` is for boundaries you do not own: network calls, the filesystem,
  the clock, randomness, third-party SDKs. Never mock a module from your own
  codebase to make a test pass.
- Control time with `vi.useFakeTimers` and `vi.setSystemTime` rather than
  waiting on real delays. Restore with `vi.useRealTimers` in `afterEach`.
- Reset shared state in `beforeEach`. Tests must pass when run alone, in any
  order, and repeated.
- No `sleep` or arbitrary timeouts to wait for something. Await the promise or
  use the runner's waiting utilities.
- No network access in a unit test. If a test needs a live service it is an
  integration test and belongs in the integration suite.

## Coverage and discipline

- A bug fix comes with a test that fails before the fix and passes after it.
- Do not skip, `it.only`, or `it.todo` in committed code.
- Do not weaken an assertion, raise a timeout, or delete a test to make a suite
  green. If a test is genuinely wrong, say why before changing it.
- Run the suite before claiming it passes, and quote the actual result.
