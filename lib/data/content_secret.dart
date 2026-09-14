/// Compile-time HMAC secret for offline content integrity.
///
/// Anti-casual-tamper only — not DRM. Anyone with the APK can extract this;
/// the goal is to catch accidental or naive edits to shipped curriculum data.
const String contentHmacSecret = 'mechalearn-vsb-content-hmac-v1';
