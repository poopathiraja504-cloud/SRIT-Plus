# SRIT Plus

SRIT Plus is a responsive Flutter application for Sri Ramakrishna Institute of
Technology, Coimbatore. It targets Android, iOS and web, and includes Firebase
authentication, Firestore-powered campus updates, a responsive campus
dashboard, and an in-app SRIT website.

## Project layout

```text
lib/
  main.dart
  firebase_options.dart
  models/
    campus_update.dart
  providers/
    auth_state_provider.dart
    campus_content_provider.dart
    theme_provider.dart
  screens/
    campus_pages.dart
    dashboard_screen.dart
    forgot_password_screen.dart
    login_screen.dart
    signup_screen.dart
    splash_screen.dart
    website_screen.dart
    website_screen_native.dart
    website_screen_web.dart
  services/
    auth_service.dart
    campus_content_service.dart
    campus_links.dart
  utils/
    app_theme.dart
  widgets/
    auth_page_shell.dart
    brand_mark.dart
firestore.rules
firestore.indexes.json
```

## Requirements

- Flutter 3.35 or later (Dart `^3.9.2`)
- Firebase project **SRIT APP** (`srit-app-d51f4`)
- Android application ID: `com.srit.app`
- iOS bundle ID: `com.srit.app`
- Xcode and macOS for iOS builds

## Firebase setup

Android and iOS configuration is included in
`android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`.
Web, Android and iOS Firebase options are in `lib/firebase_options.dart`.
Before running:

1. Enable **Email/Password** and **Google** in Firebase Console →
   Authentication → Sign-in method.
2. Register `com.srit.app` as the Android and iOS app IDs. Add your Android
   signing certificate SHA-1 and SHA-256 fingerprints to Firebase for native
   Google sign-in.
3. Add the web deployment origin to Firebase Authentication's **Authorized
   domains** for web sign-in.
4. Create the Cloud Firestore database and deploy the read-only rules and
   indexes from this repository:

   ```powershell
   firebase login
   firebase use srit-app-d51f4
   firebase deploy --only firestore:rules,firestore:indexes
   ```

The app reads only published content. Create documents in the `announcements`,
`news` and `events` collections with these fields:

| Collection | Fields |
|---|---|
| `announcements` | `title` (string), `description` (string), `published` (boolean), `publishedAt` (timestamp), optional `url` (HTTPS string) |
| `news` | `title` (string), `description` (string), `published` (boolean), `publishedAt` (timestamp), optional `url` (HTTPS string) |
| `events` | `title` (string), `description` (string), `published` (boolean), `eventDate` (timestamp), optional `url` (HTTPS string) |

Firestore writes from the client are denied. Publish content through Firebase
Console or a trusted administrative process. If Firestore is not configured
or access is denied, the dashboard displays the error and a retry action
rather than hiding the failure.

Firebase Authentication keeps its platform-default session persistence; the
dashboard restores the signed-in user on launch.

## Campus information and branding

The SRIT website is `https://www.sritcbe.ac.in/`. Native platforms use
`webview_flutter`; web uses an embedded browser frame and offers an open-in-new
tab action. Some websites block embedding in browsers. In that case, use the
web page's open-in-browser action. Campus photos load from the official SRIT
website and use a gradient fallback when unavailable. The displayed SRIT mark
is a branded monogram; replace `BrandMark` with an approved logo asset if one
is provided.

The fee-payment action currently points to the SRIT website because a verified
direct payment URL is not configured. Update `sritFeePortal` in
`lib/screens/campus_pages.dart` only after confirming the official payment
destination. Phone and email links also direct users to the current official
contact page.

## Run and build

From the project root:

```powershell
flutter pub get
flutter run
```

Build Android:

```powershell
flutter build apk --release
flutter build appbundle --release
```

Build and run web:

```powershell
flutter run -d chrome
flutter build web --release
```

## Deploy to Netlify

The root-level `netlify.toml` configures the Netlify Flutter build plugin to
install the stable Flutter SDK, build the release web app, publish `build/web`,
and route client-side paths back to `index.html`. The plugin is pinned in the
root `package.json`/`package-lock.json`. In the Netlify site settings, connect
this repository (`poopathiraja504-cloud/SRIT-Plus`) and use the `main` branch.
Leave the build command and publish directory inherited from `netlify.toml`,
or set them to the same values:

```text
Build command: flutter build web --release
Publish directory: build/web
```

After pushing changes, Netlify should start a deploy automatically. If not,
trigger one in Netlify (Deploys → Trigger deploy → Deploy site). Successful
build output must contain
`build/web/index.html`. Flutter build output is intentionally excluded from
Git; Netlify generates it from the committed Flutter sources on every deploy.

Build iOS on macOS with Xcode:

```sh
flutter build ios --release
```

The release APK is written to
`build/app/outputs/flutter-apk/app-release.apk`; the Android App Bundle is
written to `build/app/outputs/bundle/release/app-release.aab`. Configure a
private release keystore before Play Store publishing. The repository's
release Gradle signing uses the debug key for local build convenience only.
