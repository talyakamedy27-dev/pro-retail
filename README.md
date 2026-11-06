# POS Retail Pro (Flutter)

Offline-first point-of-sale app for Android & iOS (UGX, 18% VAT).

## Run
```
flutter create . --platforms=android,ios   # generates android/ and ios/ folders
flutter pub get
flutter run
```
Demo login: `owner@business.com` / `admin123`

## Features
Sales & checkout, cash/card/mobile money/bank payments, inventory (low-stock alerts), customers,
live reports (7/30-day trend, top products, payment mix), offline queue with auto-sync,
business profile & theme customization, hashed credentials, local-only card handling.

## Structure
`lib/models.dart` data · `lib/store.dart` state, persistence, analytics · `lib/screens/` 12 screens
