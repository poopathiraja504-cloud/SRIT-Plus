# SRIT PORTAL

SRIT PORTAL is a responsive Flutter application for Sri Ramakrishna Institute of
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
   SRIT PORTAL accounts, not institutional email passwords.
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
6. Create the Cloud Firestore database and deploy the read-only content rules,
   per-user FCM device-token rules, and consent-gated activity-event rules from
   this repository:

   ```powershell
   firebase login
   firebase use srit-app-d51f4
   firebase deploy --only firestore:rules,firestore:indexes
   ```

   To deploy only the composite indexes after changing
   `firestore.indexes.json`, run:

   ```powershell
   firebase deploy --only firestore:indexes --project srit-app-d51f4
   firebase firestore:indexes --project srit-app-d51f4 --pretty
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

Firebase Analytics is disabled until a user opts in. Consent can be declined or
changed in portal settings. When enabled, the app records only allowlisted
feature and authentication outcome events; it never sends passwords, tokens,
email addresses, or profile details. Authenticated activity events are appended
under `users/{authenticatedUid}/activity` with a server timestamp and can only
be created by that same user. Activity records are not readable from clients;
aggregate usage is handled by Firebase Analytics.

## Campus information and branding

Campus pages link to official SRIT information for programmes, departments,
facilities, management, placement and contact details. The web login uses an
official SRIT campus photograph from `https://www.srit.org/`; the browser loads
a responsive WebP variant (1600 or 3200 pixels wide) and uses the 6720 × 4392
original on larger displays. If the remote image is unavailable, the web page
falls back to the local 1920 × 1080 campus image. Android and iOS continue to
use that local image. The carousel uses official SRIT facilities and event
photographs. The SRIT emblem, principal portrait and Google mark are local
assets sourced from their respective official sites. The app icon sets and
web favicon use the official SRIT emblem.

On web, the dashboard has a collapsible desktop sidebar and mobile drawer.
Portal pages use the `?page=` query parameter so refreshing a page remains
within the Flutter single-page app; browser Back and Forward update the active
page. Profile details come from the authenticated Firebase Auth user. Profile
editing updates the Auth display name and photo URL; image uploads are not
configured. The current Firebase project has no approved student-record
source, so register number, department, attendance, marks, results and
timetables are explicitly unavailable rather than fabricated.

On supported Android browsers, the website offers the browser's native PWA
install prompt and falls back to browser-menu instructions when that prompt is
unavailable. On iPhone and iPad, it explains Safari's Share → Add to Home
Screen flow. Standalone installations do not show the banner, and dismissals
are remembered by the browser. The PWA manifest provides the SRIT PORTAL icons,
and the registered Firebase Messaging worker also provides a fetch handler and
network-first app-shell caching with an offline fallback. Chrome's in-page
install prompt requires a service worker with a `fetch` handler. Netlify
revalidates the app shell, worker, bootstrap and manifest after deployment.
The website's Android and desktop download section serves one universal native
Flutter APK at `/downloads/app-release.apk` (version 1.0.0, currently 50.0 MiB /
52.4 MB). It includes all supported Android ABIs. Build the universal APK with:

```powershell
flutter clean
flutter pub get
flutter build apk --release
```

The single APK is included in `web/downloads`, so Flutter copies it into
`build/web/downloads` and Netlify publishes it with the Android package MIME
type and a file-derived `Content-Length`. Android users can allow browser
installs when prompted, then install SRIT PORTAL. The current local release APK
uses the Android debug signing key and is not suitable as a permanent
production signing identity. No native iOS App Store or TestFlight release is
published; iOS visitors are not offered APK downloads and can add the website
to their Home Screen from Safari.
The web build also publishes the Google Search Console verification file,
`robots.txt`, and `sitemap.xml`. SEO metadata and structured data use the
official institutional emblem in the web icon set. Search ranking or indexing
timelines are controlled by Google and are not guaranteed.
Authentication, Firestore content, remote campus photographs and push
delivery still require their respective online services.

Firebase Authentication currently provides Google sign-in and
email/password accounts. Email/password and Firebase password reset are for
SRIT PORTAL accounts; they do not authenticate or reset institutional Google
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

On Windows, keep the Android SDK path free of spaces. If Gradle completes but
Flutter's App Bundle validation fails in `apkanalyzer`, move the SDK to a
no-space path or configure Flutter and the machine-local
`android/local.properties` to use a valid no-space path (for example, an
available 8.3 short path). Do not commit `local.properties`.

Build and run web:

```powershell
flutter run -d chrome
flutter build web --release
```

## Deploy to Netlify

The root-level `netlify.toml` configures the Netlify Flutter build plugin to
install the stable Flutter SDK, build the release web app, publish `build/web`,
and route client-side paths back to `index.html`. The plugin is pinned in the
root `package.json`/`package-lock.json`. The existing site is connected to
`poopathiraja504-cloud/SRIT-Plus` on the `main` branch.
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
