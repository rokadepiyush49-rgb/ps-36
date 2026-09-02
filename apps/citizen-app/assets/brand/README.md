# Brand assets

Drop the JanMaang logo files here. The app picks them up automatically —
`JmLogo` falls back to a typographic lockup while a file is missing, so the
build never breaks on an absent asset.

| File | Used by |
|---|---|
| `janmaang_logo.png` | Full lockup — onboarding hero, login header, splash |
| `janmaang_mark.png` | Petal mark only (square crop) — app bar, avatar, launcher icons |

Guidance:
- Export the mark as a square PNG with transparent background, 1024×1024.
- Export the full lockup at 3× the largest on-screen size (≈1200px wide).
- Launcher icons and the web favicon are generated from `janmaang_mark.png`
  with `dart run flutter_launcher_icons` (see `flutter_launcher_icons.yaml`).
