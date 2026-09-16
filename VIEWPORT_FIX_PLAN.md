# Sanctuary Viewport Fix Plan

**Project:** Idle Animals / Extinction Sanctuary  
**Target:** Dodo Island sanctuary viewport  
**Created:** 2026-09-15  
**Status:** Ready for implementation

## 1. CI Failure Diagnosis

GitHub Actions run #6 for commit `4cc866029bf54afa1d606cfd0d4fd9a3041064e2` failed during the **Run code analyzer** step.

The workflow itself is not failing because of Android, Java, Flutter installation, dependencies, or the Android build.

The exact failure is:

```text
warning • The value of the local variable 'dx' isn't used
  lib/widgets/habitat_viewport.dart:259:19

warning • The value of the local variable 'dy' isn't used
  lib/widgets/habitat_viewport.dart:260:19

2 issues found.
Process completed with exit code 1.
```

Because the workflow runs `flutter analyze` as a required step, these analyzer issues produce a non-zero exit code. Unit tests and APK compilation were therefore skipped.

### CI conclusion

The immediate build failure is a straightforward analyzer-cleanliness bug introduced in the viewport implementation. The Android build was never reached.

## 2. Immediate Fix

In `lib/widgets/habitat_viewport.dart`, `_buildAnimals()` creates:

```dart
final dx = animal.x * constraints.maxWidth * 5;
final dy = animal.y * constraints.maxHeight * 5;
```

Neither value is used.

Remove both variables and remove the unnecessary `LayoutBuilder` if it has no remaining purpose.

Do **not** silence the analyzer globally and do not change CI to ignore warnings. The goal is a clean analyzer result.

## 3. Important Viewport Rendering Audit

Fixing the analyzer failure is necessary but is not sufficient to declare the blank/gray viewport solved.

The current implementation has another structural concern in `_buildAnimals()`:

```dart
Positioned(
  left: (animal.x * 100) - 10,
  top: (animal.y * 100) - 12,
  width: 20,
  height: 32,
)
```

These positions are based on a fixed 100-pixel coordinate space rather than the actual viewport size. The animal widgets therefore cannot reliably occupy the intended habitat area on different device sizes.

The animal layer should instead position animals using the actual `Stack`/viewport dimensions, or use `Align` with normalized coordinates without wrapping the content in an artificially positioned 100x100 coordinate system.

### Required approach

Use normalized coordinates consistently:

```text
animal.x = 0.0 .. 1.0
animal.y = 0.0 .. 1.0
```

Convert them against the actual viewport size, or use an alignment-based layout that preserves those normalized coordinates.

Keep the animal layer independent from the painter so that animal layout cannot affect the painter's size.

## 4. Make the Viewport Rendering Unambiguous

The viewport must have an explicit, stable layout contract.

Required structure:

```text
Sized/Constrained Viewport
    ↓
ClipRRect
    ↓
Stack(fit: StackFit.expand)
    ├── Background
    ├── CustomPaint(child: SizedBox.expand())
    ├── Habitat objects
    ├── Animals
    └── Care feedback
```

The `CustomPaint` must receive a real non-zero size from its parent.

The painter must never depend on its child to establish an accidental size.

## 5. Add a Rendering Fallback

The viewport should visibly prove that the rendering surface exists even if individual habitat drawing operations fail.

Use a non-gray background owned by the viewport itself.

The Dodo Island scene should have a clearly visible dark ocean/sky background before the island is painted.

This makes future rendering failures immediately distinguishable from an unconstrained/collapsed widget.

## 6. Painter Audit

Review `_HabitatPainter.paint()` for all operations that can result in an effectively invisible scene.

Verify:

- `size.width > 0` and `size.height > 0` during normal rendering.
- Island ellipse is inside the viewport.
- Island dimensions remain positive on small screens.
- Gradient shader has a valid rectangle.
- Water is inside the island.
- Feeding station is inside the island.
- Fence coordinates are inside the island.
- Plants are inside the viewport.
- Level-based objects do not draw outside the clip.
- No transparent/gray paint is unintentionally covering the entire scene.

Do not add arbitrary delays, rebuild loops, or hard-coded screen sizes as a workaround.

## 7. Animation Safety

The viewport animation must remain lightweight and must not be responsible for determining layout.

Requirements:

- `AnimationController` starts after state initialization.
- `_tick()` exits when unmounted.
- `setState()` is only called while mounted.
- Animal positions remain normalized.
- Particle positions use local viewport coordinates.
- No animation value is allowed to change widget dimensions.

If necessary, temporarily disable animal/particle animation during diagnosis to prove the static painter renders correctly. Re-enable it after the static scene is verified.

## 8. Tap Interaction Verification

Tapping the viewport must:

1. Trigger the existing game care callback.
2. Animate visible animals.
3. Create a visible care particle.
4. Never remove or obscure the habitat scene.
5. Never cause an exception.

Tap feedback is secondary to reliable rendering.

## 9. Required Tests

### Analyzer

```text
flutter analyze
```

Must finish with:

```text
No issues found!
```

### Unit tests

```text
flutter test
```

Must pass completely.

### Android build

```text
flutter build apk --release
```

Must produce the release APK.

### Widget/rendering tests

Add focused tests where practical for:

- HabitatViewport builds without exceptions.
- Population 1 renders one animal.
- Population 0/invalid values do not collapse the viewport.
- Large population is capped at the intended visible count.
- Each supported biome builds successfully.
- Habitat levels 1, 3, 6, and 8 build successfully.
- Tapping invokes the callback.

## 10. Manual Device Verification

After CI succeeds, install the newly generated APK rather than reusing an older artifact.

Verify on the Android device:

### Static scene

Immediately after launch, the viewport must show:

- dark colored background;
- island/terrain;
- water;
- feeding station;
- vegetation;
- enclosure/fence;
- visible Dodos.

### Animation

Wait 5–10 seconds and confirm:

- Dodos move/idle;
- water ripple animates;
- no flicker;
- no gray replacement surface;
- no frame-rate collapse.

### Interaction

Tap several areas of the viewport and confirm:

- care animation appears;
- reward particle appears;
- Dodos react;
- scene remains visible.

### Resize/layout

Test at least the normal phone portrait layout and a smaller/alternate Android display configuration if available.

The scene must remain visible and correctly positioned.

## 11. Debug Instrumentation If Still Blank

If the next clean APK is still gray, add temporary diagnostics rather than guessing.

Record:

- viewport `constraints.biggest`;
- `RenderBox.size` for `HabitatViewport`;
- `CustomPainter.paint()` received `Size`;
- active biome;
- habitat level;
- population;
- whether `_HabitatPainter.shouldRepaint()` is firing;
- Flutter framework/rendering exceptions.

Add a temporary visible debug label showing the actual painter size, then remove it after the cause is identified.

The goal is to determine which of these is happening:

```text
A. Viewport has zero/incorrect size
B. Painter receives zero/incorrect size
C. Painter is not being invoked
D. Painter draws but is covered by another widget
E. Painter draws outside the visible bounds
F. Runtime exception prevents part of the tree from rendering
G. Android rendering/backend issue
```

## 12. CI Workflow Improvements

After the code fix, keep the workflow strict.

Recommended order:

```text
flutter pub get
↓
flutter analyze
↓
flutter test
↓
flutter build apk --release
↓
upload APK
```

Do not bypass `flutter analyze` just to produce an APK.

Optionally update deprecated workflow actions later, but that is not part of this viewport failure.

## 13. Acceptance Criteria

The viewport fix is complete only when all of the following are true:

- `flutter analyze` passes with zero issues.
- `flutter test` passes.
- Release APK builds successfully.
- The APK installs on Android.
- Dodo Island is visibly rendered instead of gray/blank.
- The painter receives a real viewport size.
- Animals are positioned relative to the actual viewport.
- Animals animate without affecting layout.
- Tap feedback works.
- No new runtime exceptions occur.
- The scene remains visible after navigation/rebuilds.
- The scene remains visible after loading a saved game.
- The viewport works for all currently supported biome types.

## 14. Implementation Order

1. Remove unused `dx`/`dy` analyzer errors.
2. Simplify/fix normalized animal positioning.
3. Verify explicit viewport sizing.
4. Verify static painter rendering first.
5. Verify habitat objects.
6. Verify animals.
7. Re-enable/verify animation.
8. Verify tap feedback.
9. Run analyzer.
10. Run tests.
11. Build release APK.
12. Install and manually verify on Android.
13. Only then continue visual polish.

## 15. Do Not Do

- Do not ignore analyzer warnings.
- Do not remove CI validation.
- Do not hard-code a 100x100 viewport.
- Do not switch to Flame just to hide the issue.
- Do not add random rebuilds or timers to force painting.
- Do not replace the scene with a static screenshot.
- Do not declare the viewport fixed because the code compiles.

The objective is a reliable, properly sized, genuinely rendered sanctuary viewport that works across Android device sizes and survives normal Flutter rebuilds.
