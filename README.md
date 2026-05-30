# SongketAI

A Flutter mobile app for generating new Songket motifs with a **Conditional Deep Convolutional Generative Adversarial Network (cDCGAN)**.

The app is the client side of a larger system: **Flutter (UI) → REST API (FastAPI) → cDCGAN (PyTorch) → PostgreSQL**. The user picks a motif category, configures the generation (resolution, attribute conditions, noise seed), sends a request to the backend, then views, saves, and downloads the generated motif.

> **Current stage — UI-first.** This repository contains the complete mobile UI (10 screens) plus a pluggable data layer. All data is currently served from an in-memory **mock** source. The REST API contract is already defined so the backend can be plugged in later without touching the UI. The FastAPI backend, cDCGAN model, and PostgreSQL database are out of scope at this stage.

## Features

- **Splash** — branded launch screen with model-initialization indicator.
- **Home** — welcome banner and a grid of recent generations.
- **Categories** — searchable grid of Songket motif categories.
- **Configure** — output resolution (64×64 / 128×128), multi-select attribute conditions, and an optional noise seed for reproducible results.
- **Generating** — live generation flow with a progress bar and a streaming process log.
- **Result** — generated motif preview with save, download (PNG), and feedback actions.
- **History & Detail** — list of past generations with sort/filter, plus a detail view with metadata, re-download, and delete.
- **Settings** — backend API URL, default resolution, theme toggle, and app version.
- **About** — research metadata and a summary of the cDCGAN architecture.

## Architecture

Feature-first structure with a clear separation between presentation, state, domain, and data layers.

```
lib/
├── main.dart                 # Bootstrap: ProviderScope + SharedPreferences
├── app.dart                  # MaterialApp.router + theme
├── core/
│   ├── config/               # App constants, data-source switch (mock/api)
│   ├── router/               # go_router config + route names
│   ├── theme/                # Monochrome design tokens + ThemeData
│   ├── widgets/              # Reusable UI components
│   ├── error/                # AppException taxonomy + Failure
│   └── network/              # Dio API client + endpoints
├── domain/
│   ├── models/               # Immutable data models + enums
│   └── repositories/         # MotifRepository interface
├── data/
│   ├── mock/                 # In-memory mock data (active)
│   ├── repositories/         # MockMotifRepository (active) + ApiMotifRepository (stub)
│   └── services/             # File download + settings persistence
├── providers/                # Riverpod providers (repository + settings bindings)
└── features/                 # One folder per screen (presentation + controllers)
```

**Pluggable data source.** The UI and state layers depend only on the `MotifRepository` interface. `motifRepositoryProvider` selects the concrete implementation:

- `MockMotifRepository` — in-memory, offline, active by default.
- `ApiMotifRepository` — REST implementation over `ApiClient` (Dio), ready to enable.

Switch at build time with a compile-time flag (default is `mock`):

```bash
flutter run --dart-define=DATA_SOURCE=api
```

## Tech Stack

- **Flutter / Dart**
- **Riverpod** — state management and dependency injection
- **go_router** — declarative routing with a `StatefulShellRoute` bottom navigation
- **Dio** — HTTP client (used by the API repository)
- **shared_preferences** — local settings persistence
- **path_provider** / **permission_handler** — file download + storage permission
- **google_fonts** — Lora (serif headings) + Inter (sans body)
- **intl** — date formatting
- **glados** — property-based testing

## Design

Monochrome / grayscale, minimalist visual style: serif headings, uppercase letter-spaced labels, solid black primary buttons, outlined secondary buttons, thin-border rounded cards, and a 3-tab bottom navigation (Generate / History / Settings).

## Getting Started

Requirements: Flutter SDK (Dart `>=3.1.5 <4.0.0`).

```bash
flutter pub get
flutter run
```

## Testing

The project uses unit, widget, and property-based tests. Ten correctness properties from the design (JSON round-trip, navigation consistency, generate state-machine transitions, progress monotonicity, seed reproduction, and more) are validated with property-based tests.

```bash
flutter test       # run the full suite
flutter analyze    # static analysis
```

## Project Status

| Area | Status |
|------|--------|
| Mobile UI (10 screens) | ✅ Implemented |
| Pluggable data layer (mock active, API stub ready) | ✅ Implemented |
| REST API contract | ✅ Defined |
| FastAPI backend | ⬜ Not started |
| cDCGAN model (PyTorch) | ⬜ Not started |
| PostgreSQL database | ⬜ Not started |

## Author

Giovanni Yuda Prastika — Teknologi Rekayasa Perangkat Lunak, Politeknik Negeri Padang.
