# NewsApp

A simple **SwiftUI** news reader for **top headlines** using the [NewsAPI](https://newsapi.org/) free tier. It shows a searchable list with thumbnails, an article detail screen, and offline-friendly caching.

## Features

- **Top headlines** with thumbnail, title, and source
- **Article detail** with description and **Read More** (opens the article in the system browser)
- **Search / filter** by keyword (NewsAPI `q` parameter)
- **MVVM-style** structure: views + `HeadlinesViewModel`, networking behind a `NewsFetching` protocol
- **Async/await** end-to-end (`URLSession`, no third-party HTTP libraries)
- **Offline cache** via `UserDefaults` (TTL + stale fallback when the network fails)
- **Unit tests** for JSON decoding and cache behavior (`NewsCore` Swift package)

## Requirements

- Xcode **16+** (project targets recent Apple platforms)
- A free **NewsAPI** key — register at [newsapi.org/register](https://newsapi.org/register)

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/Aqib114/NewsApp.git
cd NewsApp
```

### 2. Add your API key (do not commit real keys)

1. Open `newsapp.xcodeproj` in Xcode.
2. Select the **newsapp** target → **Build Settings**.
3. Click **+** → **Add User-Defined Setting**.
4. Name: **`NEWS_API_KEY`**
5. Value: your NewsAPI key.

The target merges `newsapp/Resources/Info.plist`, which contains `$(NEWS_API_KEY)` so Xcode substitutes your key at build time.

### 3. Run the app

Choose an iOS Simulator or **My Mac** (if supported by your scheme), then **Run** (⌘R).

If the key is missing or invalid, the app shows a **Missing NewsAPI Key** screen.

## Run unit tests (SwiftPM)

From the repository root:

```bash
swift test
```

This runs `NewsCoreTests` (decoding + `UserDefaults` cache round-trip / TTL).

## Project structure

```
newsapp/
├── Application/          # App entry, ContentView
├── Core/Config/          # AppConfig (reads NEWS_API_KEY from Info.plist)
├── Presentation/         # SwiftUI + ViewModels (Headlines, Article detail)
├── Data/
│   ├── API/              # NewsAPIClient, NewsAPIError, NewsFetching
│   ├── Models/           # Codable models
│   └── Cache/            # UserDefaultsNewsCache, CachedNewsService
└── Resources/            # Info.plist, Assets
```

Root level:

- `Package.swift`, `Sources/NewsCore/`, `Tests/NewsCoreTests/` — shared test module for parsing/cache logic.

## Architecture (short)

| Layer | Responsibility |
|--------|----------------|
| **Presentation** | SwiftUI views, `HeadlinesViewModel` (`@MainActor`, `ObservableObject`) |
| **Data** | `NewsAPIClient` (URLSession), `CachedNewsService` wrapping cache + network |
| **Core** | `AppConfig` for secrets / build-time configuration |

## License

This project is for learning and demonstration. News content is provided by [NewsAPI](https://newsapi.org/); use complies with their [terms](https://newsapi.org/terms).
