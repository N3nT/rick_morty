# Rick & Morty App

Aplikacja mobilna napisana we **Flutterze**, wyświetlająca dane z [Rick and Morty API](https://rickandmortyapi.com). Umożliwia przeglądanie postaci, epizodów i lokacji ze świata serialu, a także zapisywanie ulubionych bohaterów.

---

## Funkcjonalności

- **Lista postaci** z paginacją, wyszukiwaniem i filtrami (status, płeć, gatunek, typ)
-  **Lista epizodów** z podziałem na sezony
-  **Lista lokacji** z ikonami typów
-  **Ulubione** — dodawanie i usuwanie postaci z listy ulubionych
-  **Ekrany szczegółów** dla postaci, epizodów i lokacji
-  **Tryb offline** — dane przechowywane lokalnie w Hive
-  **Pull-to-refresh** — odświeżanie danych gestem przeciągnięcia

---

## Technologie

| Technologia | Zastosowanie |
|---|---|
| Flutter | Framework mobilny |
| Dart | Język programowania |
| `http` | Zapytania REST API |
| `hive_flutter` | Lokalna baza danych (offline) |
| Firebase Analytics | Analityka i eventy |
| Firebase Crashlytics | Monitorowanie błędów |

---

## REST API

Aplikacja korzysta z [Rick and Morty API](https://rickandmortyapi.com) — darmowego, publicznego API niewymagającego klucza.

Używane endpointy:

```
GET /character           — lista postaci (paginacja + filtry)
GET /character/:id       — szczegóły postaci
GET /episode             — lista epizodów
GET /episode/:id         — szczegóły epizodu
GET /location            — lista lokacji
GET /location/:id        — szczegóły lokacji
```

---

## Struktura projektu

```
lib/
├── main.dart
├── models/
│   ├── character.dart
│   ├── episode.dart
│   └── location.dart
├── services/
│   ├── api_service.dart
│   └── database_service.dart
└── screens/
    ├── main_screen.dart
    ├── characters_screen.dart
    ├── character_detail_screen.dart
    ├── favorites_screen.dart
    ├── episodes_screen.dart
    ├── episode_detail_screen.dart
    ├── locations_screen.dart
    └── location_detail_screen.dart
```

---

## Uruchomienie

1. Sklonuj repozytorium:
   ```bash
   git clone https://github.com/N3nT/rick_morty
   cd rick_morty
   ```

2. Zainstaluj zależności:
   ```bash
   flutter pub get
   ```

3. Uruchom aplikację:
   ```bash
   flutter run
   ```

> Wymagany Flutter SDK w wersji 3.0 lub nowszej.

---
