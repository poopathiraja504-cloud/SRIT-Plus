# SRIT Plus

SRIT Plus is a Flutter Android app for Sri Ramakrishna Institute of Technology.
It includes Firebase email/password and Google sign-in, password reset, a
responsive campus dashboard with navigation drawer, campus information pages,
and an in-app SRIT website powered by WebView.

## Project layout

```text
lib/
  main.dart
  firebase_options.dart
  screens/
    splash_screen.dart
    login_screen.dart
    signup_screen.dart
    forgot_password_screen.dart
    dashboard_screen.dart
    campus_pages.dart
    website_screen.dart
  services/
    auth_service.dart
    campus_links.dart
  widgets/
    auth_page_shell.dart
    brand_mark.dart
```

## Firebase setup

App name: **SRIT Plus**. The Firebase project is **SRIT APP**
(`srit-app-d51f4`), and the Android application ID is `com.srit.app`.

1. In Firebase Console, enable **Email/Password** and **Google** under
   Authentication → Sign-in method.
2. Confirm that the Android app registered in Firebase has package name
   `com.srit.app`, and use its `google-services.json` at
   `android/app/google-services.json`.
3. Add the SHA-1 and SHA-256 fingerprints of your debug and release signing
   certificates to the Firebase Android app for Google sign-in.
4. If using another Firebase project, replace `lib/firebase_options.dart` and
   `android/app/google-services.json` with files generated for that project.

## Campus links and institution content

The official site currently linked by the app is
`https://www.sritcbe.ac.in/`. Update `sritFeePortal`, `sritContactPage`,
`sritMapsLocation`, and any official-page actions in
`lib/screens/campus_pages.dart` if the direct portals or paths change. The
fee button currently opens the official SRIT website because a separate
payment portal URL is not published in the app configuration; set
`sritFeePortal` to the verified payment destination before publishing. The
displayed contact page links to the official site for current phone and email
details. The website screen keeps SRIT pages in-app and offers refresh, back,
and open-in-browser controls.

The authentication and dashboard hero use campus imagery from the official
SRIT website. Network access is required to load these images; a gradient
fallback is shown when they are unavailable. Replace `BrandMark` in
`lib/widgets/brand_mark.dart` with the institution's approved logo asset if one
is supplied.

## Run and build

Install Flutter 3.35 or newer (the project requires Dart SDK `^3.9.2`), then
from the project root:

```powershell
flutter pub get
flutter run
```

To create a release APK:

```powershell
flutter build apk --release
```

The APK is written to
`build/app/outputs/flutter-apk/app-release.apk`. For Play Store distribution,
configure a private release keystore and update the release signing
configuration in `android/app/build.gradle.kts`; the checked-in debug signing
configuration is only for local builds.
