---
description: React Native and Expo stack choices, storage, styling, state, and builds
---

# React Native

Link this only in a React Native or Expo app. None of it is true in a web or
backend repository.

## Storage

- Use MMKV via `react-native-mmkv` for all key-value storage.
- Never use `AsyncStorage` or `@react-native-async-storage/async-storage`.
- Never use `expo-secure-store`.
- Create one MMKV instance in a single module and import it. Do not construct a
  new instance at each call site.

  ```ts
  export const storage = new MMKV()
  ```

- MMKV is synchronous. Do not wrap reads in `await` or in a promise.
- For a persisted store adapter, back it with MMKV rather than pulling in a
  second storage library.

## Routing

- Use `expo-router` with file-based routes. Do not wire React Navigation
  navigators by hand.
- Enable typed routes and use the generated `Href` types. Navigate with `router`
  or `<Link>`, not with untyped string concatenation.
- Route groups `(tabs)` and `(auth)` carry layout, not business logic. Keep
  screens thin and put logic in hooks or modules.

## State

- Zustand for client state. One store per domain, selectors at the call site so
  a component re-renders only on the slice it reads.

  ```ts
  const user = useSessionStore((state) => state.user)
  ```

  Not `const { user } = useSessionStore()`.

- TanStack Query for anything that comes from the network. Server data does not
  go in Zustand.
- Do not add Redux, MobX, or Recoil. Do not use React Context as a state
  container, only for genuinely static dependency injection.

## Styling

- NativeWind. Style with `className` using Tailwind classes.
- Do not write `StyleSheet.create` objects or inline `style` props for anything
  NativeWind can express. An inline `style` is acceptable for a value computed
  at runtime, such as an animated transform.
- Keep the design tokens in `tailwind.config.js`. Do not hardcode hex colours or
  pixel values in components.
- Tailwind class names are American English by specification. Write
  `text-center` and `bg-gray-100` as the library defines them.

## Components

- One component per file, named export, arrow function assigned to a `const`.
- Use the platform components from `react-native`. Do not import `div`, `span`,
  or anything from `react-dom`.
- Extract a subcomponent rather than adding a third level of nesting inside JSX.
- Wrap screens in `SafeAreaView` from `react-native-safe-area-context`, not the
  deprecated one from `react-native`.
- Lists render through `FlatList` or `FlashList` with a stable `keyExtractor`.
  Never `.map` a large array into JSX inside a `ScrollView`.

## Platform differences

- Branch with `Platform.OS` or `Platform.select` at the smallest scope that
  works. Do not fork a whole screen for a one-property difference.
- Use `.ios.tsx` and `.android.tsx` file extensions only when the two
  implementations genuinely diverge.
- Never assume a web API exists. No `window`, `document`, `localStorage`, or
  DOM events.
- Test a change on both platforms before calling it done, or say which one it
  was checked on.

## Performance

- Memoise list item components and keep `renderItem` stable.
- Do not create a new function, object, or array literal inside a hot render
  path that feeds a memoised child.
- Use `expo-image` rather than the built-in `Image` for remote images.
- Keep work off the JS thread where a native equivalent exists. Do not animate
  by setting state every frame.

## Builds

- Builds go through EAS. Configure profiles in `eas.json` and keep `development`,
  `preview`, and `production` distinct.
- Never commit credentials, keystores, provisioning profiles, or `.p8` keys.
  EAS holds them.
- Secrets reach the app through EAS environment variables. Anything prefixed
  `EXPO_PUBLIC_` is embedded in the bundle and is not a secret.
- Do not hand-edit `ios/` or `android/` native directories. Express native
  changes as a config plugin or in `app.json` so a prebuild does not discard
  them.
- Bump `runtimeVersion` when a change touches native code, so an over-the-air
  update cannot land on an incompatible binary.
- Do not run `expo prebuild`, `eas build`, or `eas submit` unless asked. They
  cost time and can overwrite native directories.
