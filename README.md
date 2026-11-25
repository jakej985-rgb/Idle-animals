# Extinction Sanctuary

An idle game about rebuilding sanctuaries for extinct species. You revive
animals with DNA, keep their habitats fed and watered, breed them back to a
stable population, and restore each ecosystem for permanent bonuses. Progress
is saved locally with `shared_preferences`, and the time you spend away is
simulated when you come back.

Built with Flutter and Riverpod.

## Requirements

- Flutter **3.50.1** (stable) with Dart 3.14

The version is pinned in CI because the golden tests in `test/goldens/` were
generated with it; a different Flutter versions rasterises text differently and
fails those tests. When bumping Flutter, regenerate the goldens in the same
commit (`flutter test --update-goldens`).

## Run

```bash
flutter pub get
flutter run
```

To run the web build locally:

```bash
flutter run -d chrome
```

## Check

```bash
flutter analyze
flutter test
```

The suite covers the simulation engine, save migration and corruption recovery,
offline progress, restoration, multi-habitat rules, theme contrast, widget
behaviour and two UI goldens.

## Release

- `.github/workflows/release.yml` builds a signed Android APK and publishes a
  GitHub release on every push to `main` and on `v*` tags. Signing keys come
  from repository secrets; without them the build falls back to debug signing.
- `.github/workflows/ci.yml` runs `flutter analyze` and `flutter test` on pull
  requests and on `main`.
- `scripts/build_web_release.sh` produces the web bundle.

## Layout

| Path | What lives there |
|------|------------------|
| `lib/core/simulation` | Tick engine and the shared production-rate formula |
| `lib/core/offline` | Away-time simulation and the offline report |
| `lib/core/save` | JSON persistence, migration and corruption recovery |
| `lib/models` | Immutable game state, species, habitats, upgrades |
| `lib/providers` | `GameNotifier`: actions, autosave, app lifecycle |
| `lib/screens`, `lib/widgets` | Sanctuary screen, sheets and modals |
| `lib/theme` | Colour tokens, radii and text styles |
