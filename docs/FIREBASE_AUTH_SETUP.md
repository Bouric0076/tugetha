# Firebase Phone Auth Setup

Tugetha currently uses Firebase Auth phone OTP as the temporary login bridge while the Spring Boot backend becomes the source of truth.

## Android Debug Fingerprints

The connected local debug keystore currently reports:

- SHA1: `BD:5C:26:F5:7E:69:11:38:6B:3D:6C:28:6F:66:C2:A4:F8:EC:77:02`
- SHA256: `E2:10:7F:E2:CF:61:DD:D9:36:05:A2:B1:E5:A2:4D:E1:40:FB:73:18:97:B9:FA:43:CE:29:5C:CD:96:2B:89:5E`

Add both to the Firebase Android app for package `com.sinaps.tugetha`, then download a fresh `google-services.json`.

## App Check

Debug builds use the Firebase App Check debug provider. Release builds use Play Integrity on Android and App Attest on iOS.

When running a debug build, logcat prints a debug App Check token. Add that token to Firebase Console before enabling App Check enforcement for debug traffic.

## Required Firebase Console Checks

- Phone provider enabled under Authentication.
- Android package name is `com.sinaps.tugetha`.
- SHA1 and SHA256 fingerprints added.
- Fresh `google-services.json` installed after fingerprint changes.
- If App Check enforcement is enabled, debug token must be allow-listed for debug devices.
