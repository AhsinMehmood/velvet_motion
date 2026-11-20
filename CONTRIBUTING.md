# Contributing to Velvet Motion

Thanks for helping make Flutter motion feel better.

## Setup

```bash
git clone https://github.com/AhsinMehmood/velvet_motion.git
cd velvet_motion
flutter pub get
cd example && flutter pub get && cd ..
```

## Checks

```bash
dart format .
flutter analyze
flutter test
```

Update goldens (Linux CI is the source of truth for golden images):

```bash
flutter test --tags golden --update-goldens
```

## Code style

- Run `dart format` and keep `flutter analyze` clean
- Dartdoc every public API
- Prefer springs over duration curves
- Keep animations interruptible
- Honour reduce motion
- No runtime dependencies beyond the Flutter SDK
- Target 60–120 Hz: ticker-driven physics, transform/opacity first

## Proposing a new animation

Open an issue with the **animation proposal** template: what it looks like, where apps use it, a reference video if you have one, and a sketch of the public API.

## Commits and branches

- Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, `test:`, `chore:`)
- Keep PRs focused; one animation or concern per PR when possible

## Good first issues

Docs polish, example gallery screens, tests, small spring presets, and accessibility fixes are great places to start. Look for the `good first issue` label.
