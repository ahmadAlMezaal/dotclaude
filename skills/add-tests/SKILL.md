---
name: add-tests
description: Write tests for a file, a module, or the current diff. Use when asked to add tests, write a test, cover something with tests, improve coverage, or add a regression test for a bug. Runner and assertion conventions are enforced automatically.
---

# Add tests

Runner, placement, mocking, and assertion rules come from the `testing` rule.
Follow that file. This skill is the procedure for arriving at a good test.

## Before writing

1. Read the code under test properly. A test written from the function name
   tests the name, not the behaviour.
2. Check whether a test file already exists next to it. Extend it rather than
   creating a second one.
3. Find the existing test suite's setup: helpers, factories, fixtures. Use them
   instead of building a parallel set.

## Choose what to test

4. List the behaviours a caller can observe: the happy path, each way it can
   fail, and the boundaries. Then write one `it` per behaviour.
5. Cover the cases that actually break: empty input, a missing optional field,
   a rejected promise, a boundary value, a second call after the first.
6. Do not write a test that only proves the language works. Asserting that a
   constant equals itself is noise that still has to be maintained.
7. If the code is hard to test, say so and name the reason. Usually it is doing
   two things, and the fix is to split it rather than to reach for a mock.

## For a bug fix

8. Write the failing test first. Run it and confirm it fails for the intended
   reason, not because of a typo in the test.
9. Apply the fix, then confirm the same test passes. Quote both results.
10. Name it after the bug's behaviour, not its ticket or its cause.

## Finish

11. Run the new tests, then run the whole file's suite, then confirm nothing
    else broke.
12. Run the new tests a second time in isolation. A test that passes only after
    its neighbours have run is sharing state.
13. Report the real output. If a test is skipped, flaky, or slow, say so rather
    than reporting a green count.
