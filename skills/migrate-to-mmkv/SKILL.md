---
name: migrate-to-mmkv
description: Move React Native storage from AsyncStorage or expo-secure-store to MMKV. Use when asked to migrate, replace, or rip out AsyncStorage, @react-native-async-storage/async-storage, SecureStore, or expo-secure-store, or when storage reads need to stop being async. React Native and Expo apps only.
---

# Migrate to MMKV

Only applies in a React Native or Expo app. If the repo has no React Native
dependency, say so and stop.

## Find every call site

1. Grep for all of it before changing anything:
   `AsyncStorage`, `async-storage`, `SecureStore`, `expo-secure-store`,
   `getItem`, `setItem`, `removeItem`, `multiGet`, `multiSet`, `clear`.
2. Include persisted store adapters. A Zustand `persist` config or a TanStack
   Query persister usually hides one, and it will not match a `getItem` grep.
3. List what you found and what each key holds before editing. A migration that
   misses a key silently logs the user out.

## Set up the instance

4. One MMKV instance in one module, exported, imported everywhere. Never
   construct a new instance at a call site.
5. If the old code used `expo-secure-store`, the values were encrypted at rest.
   MMKV takes an `encryptionKey` for the same job. Say plainly if you are
   creating an instance without one, because that is a security change and the
   user needs to make that call, not you.

## Convert the calls

6. MMKV is synchronous. Remove the `await`, and then remove the `async` from any
   function that was only async because of storage. Follow that upward: a hook
   that no longer needs to be async should stop returning a promise.
7. Map the API honestly. `getItem` returns `string | null`, but MMKV has
   `getString`, `getNumber`, and `getBoolean` and returns `undefined` when a key
   is absent. Check every truthiness test and every `=== null` after converting.
8. `multiGet` and `multiSet` have no direct equivalent. Replace with individual
   calls, not a wrapper that fakes the old shape.
9. Objects were `JSON.stringify`d into AsyncStorage. Keep doing that with
   `set` and `getString`, and keep the parse guarded.

## Migrate the existing data

10. Users already have data in the old store. Write a one-time migration that
    reads the old keys, writes them to MMKV, then clears the old store, guarded
    by a flag so it runs once.
11. The migration reads from AsyncStorage, so it must run before any code reads
    from MMKV, and it is the last place the old dependency is allowed to appear.
12. Delete the migration only after a release where every user has run it. Say
    that it is temporary rather than leaving it to be discovered later.

## Finish

13. Remove the old package from `package.json` once nothing imports it. If the
    migration still needs it, say so and leave it with a stated reason.
14. Test the migration path explicitly: a fresh install, and an upgrade with
    existing data in the old store.
15. Run the app on both platforms, or say which one it was checked on.
