# Proactive Expense Manager

Expense tracker with local SQLite storage and manual cloud sync.

## Run

```bash
flutter pub get
flutter run
```

## Release APK

```bash
flutter build apk --release
```

APK path: `build/app/outputs/flutter-apk/app-release.apk`

## Stack

- Flutter + BLoC
- sqflite (categories, transactions)
- shared_preferences (auth token, nickname, monthly limit)
- flutter_local_notifications (budget alert)
- HTTP sync to `https://appskilltest.zybotech.in`

## Main flows

**Auth:** phone → OTP → home (new users set nickname first).

**Sync (profile):** delete soft-deleted rows on server, upload new categories, then transactions.

**Home:** income/expense totals, monthly limit, recent transactions. Full list via “See All”.

## Repo

Push a public GitHub repo before submitting the test.
