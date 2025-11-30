# 🔐 Firebase & Supabase Config Setup

## ⚠️ Important: Config Files NOT in Git

The following files contain sensitive API keys and are excluded from version control:

- `ios/Runner/GoogleService-Info.plist`
- `android/app/google-services.json`
- `.env`

## 🚀 Setup Instructions

### 1. Firebase Setup (iOS)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `lobi-mobileapp-1ac2a`
3. **iOS App** → Download `GoogleService-Info.plist`
4. Copy to: `ios/Runner/GoogleService-Info.plist`

### 2. Firebase Setup (Android)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `lobi-mobileapp-1ac2a`
3. **Android App** → Download `google-services.json`
4. Copy to: `android/app/google-services.json`

### 3. Environment Variables

Create `.env` file in project root:

```env
# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Google Maps (optional)
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### 4. Run App

```bash
flutter pub get
flutter run
```

## 📱 Push Notifications

Push notifications are configured via:
- **Firebase**: APNs key uploaded to Firebase Console
- **Supabase**: Edge Function `send-push-notification`
- **Bundle ID**: `com.lobi.app`

## 🔑 Keys Location

- **Firebase Server Key**: Supabase Secrets (for Edge Function)
- **Service Account**: Supabase Secrets (for FCM v1 API)
- **Supabase Keys**: Dashboard → Settings → API
