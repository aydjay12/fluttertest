# Flutter Posts (JSONPlaceholder)

Modern Flutter app that fetches and displays blog posts from `https://jsonplaceholder.typicode.com/posts`.

## Preview
- List of posts with smooth Material motion (container transform)
- Pull-to-refresh, loading states, and error with retry
- Responsive and accessible typography via Google Fonts

## Architecture
- MVVM using a Stacked approach:
  - Model: `Post`
  - ViewModel: `PostsNotifier` (Riverpod `StateNotifier`)
  - View: `PostsPage` and item/detail views
- State management: Riverpod
- Networking: Dio

Project structure:
```
lib/
  app/
    app.dart                 # App root, theming, routing
  features/
    posts/
      models/post.dart       # Data model
      services/posts_service.dart   # API client (Dio)
      providers/posts_providers.dart # ViewModel + providers
      views/posts_page.dart  # UI (list, error, detail)
  main.dart
```

## Getting Started

### Prerequisites
- Flutter SDK installed
- Dart 3.9+ (as defined in `pubspec.yaml`)

### Install dependencies
```bash
flutter pub get
```

### Run
```bash
flutter run
```

### Test (sample widget test exists)
```bash
flutter test
```

## How it Works
- `JsonPlaceholderPostsService` uses Dio to GET `/posts` and maps JSON to `Post` models.
- `PostsNotifier` exposes `PostsState { isLoading, posts, errorMessage }` and async actions:
  - `loadPosts()` for initial load with spinner and error capture
  - `refreshPosts()` for pull-to-refresh (propagates errors to the indicator)
- `PostsPage` listens to the state and renders:
  - Loading indicator
  - Error view with Retry
  - `ListView.separated` with Material container transform to detail

## Packages
- `flutter_riverpod`: Scoped, testable state management.
- `dio`: Robust HTTP client with helpful errors.
- `google_fonts`: Modern, legible typography (Raleway).
- `animations`: Material motion container transform.

## Notes
- Proper async/await, error handling, and UX states are implemented.
- Follows clean code practices: small files, clear names, early returns.

