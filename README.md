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
   Google sign-in. The existing Google provider, OAuth client configuration,
   Android package, iOS bundle ID and iOS URL scheme are retained.
3. Add the web deployment origin to Firebase Authentication's **Authorized
   domains** for web sign-in.
4. Configure Firebase Authentication email-verification and reset-email
   templates. New email/password sign-ups receive a verification email;
   unverified email/password accounts see a verification screen until they
   verify. Existing Firebase users are not deleted or migrated. Google sign-in
   remains unchanged. Email verification and Firebase password reset concern
   SRIT Plus accounts, not institutional email passwords.
5. To enable push notifications, enable Firebase Cloud Messaging for the same
   Firebase project. Upload an APNs authentication key in Firebase Console and
   enable Push Notifications for the iOS App ID and signing profile. Android
   users grant notification permission from the app's **Enable notifications**
   menu item. For web, create a Web Push certificate in Firebase Console and
   build with its **public VAPID key**:

   ```powershell
   flutter build web --release --dart-define=FCM_WEB_VAPID_KEY=<public-vapid-key>
   ```

   The VAPID key is public client configuration; never put service-account
   credentials or private keys in the app. Web background notifications use
   `web/firebase-messaging-sw.js`; notification data may include a `section`
   value matching a campus page title to open that page when tapped. Use a
   trusted server or Cloud Function with server-side credentials to send
   notifications. No notification-sending backend is configured in this
   repository.
6. Create the Cloud Firestore database and deploy the read-only content rules
   and per-user FCM device-token rules from this repository:

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

FCM device tokens are written only under
`users/{authenticatedUid}/devices/{token}`. A user can write and delete only
their own device-token records; clients cannot read those records or modify
other content. Signing out removes the current device token when messaging is
configured. Firebase manages expiration for tokens belonging to uninstalled
apps.

## Campus information and branding

The current official SRIT website is `https://www.sritcbe.ac.in/`. Campus
pages link to official SRIT information for programmes, departments,
facilities, management, placement and contact details. The campus background,
SRIT emblem, principal portrait and Google mark used in the interface are
local image assets sourced from their respective official sites. The campus
background is a 1920 × 1080 optimized image. The app icon sets and web favicon
use the official SRIT emblem.

On supported Android browsers, the website offers the browser's native PWA
install prompt and falls back to browser-menu instructions when that prompt is
unavailable. On iPhone and iPad, it explains Safari's Share → Add to Home
Screen flow. Standalone installations do not show the banner, and dismissals
are remembered by the browser. No verified Play Store or App Store listing is
configured, so the website does not link to an unpublished native app.
Flutter's generated web service worker caches the app shell; authentication,
Firestore content and push delivery still require their respective online
services.

Firebase Authentication currently provides Google sign-in and
email/password accounts. Email/password and Firebase password reset are for
SRIT Plus accounts; they do not authenticate or reset institutional Google
Workspace passwords. Google sign-in is not restricted to an administrator-
approved SRIT Workspace domain or allowlist in this project. Configure the
institution-approved eligibility policy before presenting it as
SRIT-exclusive. No student-record system or approved schema is configured;
personal attendance, marks, fees and timetable records are therefore not
displayed.

FCM requires Firebase Console configuration in addition to the client code.
Web push needs a VAPID public key at build time; iOS push needs an APNs key,
an enabled Apple Push capability and a matching provisioning profile.
Notification sending also requires a trusted server-side sender. These
external services cannot be enabled or tested from repository changes alone.

Native platforms use `webview_flutter`; web uses an embedded browser frame and
offers an open-in-new-tab action. Some websites block embedding in browsers.
In that case, use the web page's open-in-browser action.

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
