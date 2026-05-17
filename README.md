# Proactive Expense Manager

Local-first expense tracker built for the Flutter Skill Test. Data is stored in SQLite on device; cloud backup runs when the user taps **Sync To Cloud** on the Profile screen.

## Tech stack

| Area | Package |
|------|---------|
| State | `flutter_bloc`, `equatable` |
| Local DB | `sqflite` |
| IDs | `uuid` |
| Notifications | `flutter_local_notifications` |
| HTTP | `http` |
| Prefs | `shared_preferences` |
| Loading UI | `shimmer` |

**API base URL:** `https://appskilltest.zybotech.in`

## Features

- 3-screen onboarding walkthrough
- Phone + OTP auth (OTP shown on screen for testing)
- SQLite schema: `categories`, `transactions` (UUID PKs, soft delete, sync flags)
- SQL `JOIN` for transaction list with category names
- Home: total income/expense, monthly limit, 10 recent transactions
- Transactions tab: full list
- Profile: nickname, alert limit (default ₹1000), category CRUD, cloud sync, logout
- Budget notification when a new debit pushes monthly spend over the limit
- Cloud sync: purge soft-deletes → upload categories → upload transactions

## Run locally

```bash
flutter pub get
flutter run
```

## Build APK (deliverable)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Project structure

```
lib/
├── main.dart                 # DI + app root
├── core/                     # theme, prefs, notifications, constants
├── data/                     # api, sqlite, models, repositories
└── presentation/             # blocs, screens, widgets
```

## Auth flow

1. `POST /auth/send-otp/` → `user_exists`, `otp`, optional `token`/`nickname`
2. User enters OTP (validated client-side against API response)
3. Existing user → save token + nickname → Home
4. New user → nickname → `POST /auth/create-account/` → save token → Home

## Sync flow

1. Soft-deleted rows → `DELETE` batch endpoints → hard-delete locally on `deleted_ids`
2. Unsynced categories → `POST /categories/add/` per row → `is_synced = 1`
3. Unsynced transactions → `POST /transactions/add/` batch → `is_synced = 1`

## GitHub

Push to a **public** repository before submission.

## Figma

[Design file](https://www.figma.com/design/PvKsf3DiyHlvVto41QGBHp/Skill-Test-Expense-Tracker)

Export additional onboarding raster images from Figma into `assets/images/` if you want pixel-perfect onboarding art beyond the bundled logo.
