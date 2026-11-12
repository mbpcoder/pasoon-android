# pasoon-android
Pasoon Android App

Test line.

## Features (v1, offline)

- Today card: Jalali, Gregorian and Hijri (Shia) dates and today's events; tap to open the month calendar
- Owghat (Tehran method, calculated on device), Tehran by default, city picker
- Jalali month calendar: swipe or tap previous/next month, tap a day to see its events
- Local events (SQLite): add, edit, delete

Stack: Flutter, Riverpod, sqflite, shared_preferences, [pasoonate](https://github.com/pasoonate/pasoonate-dart), adhan.

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Releases

Pushing a tag like `v1.0.0` runs `.github/workflows/release.yml`, which builds a signed APK and attaches it to a GitHub Release.

Required repository secrets:

| Secret | Value |
|---|---|
| `KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | keystore password |
| `KEY_ALIAS` | key alias, e.g. `upload` |
| `KEY_PASSWORD` | key password |

Create the keystore once and keep it safe; losing it means users can't update the app:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
