/// Content pack version + expected HMAC (Architect PATCH v1.1).
class ContentManifest {
  /// Bump on any shipped curriculum change (additive packs preferred).
  static const String contentVersion = '1.1.0';

  static const String hmacAlgorithm = 'HmacSHA256';

  /// Expected HMAC-SHA256 hex of signed payload (content_version + exercise answers).
  /// Recompute with `dart run tool/compute_content_hmac.dart` after content edits.
  static const String contentHmacHex =
      'ae197117598e5de25097dc51c1e520709eab813f4b9212bb7e4907a6564913a0';
}
