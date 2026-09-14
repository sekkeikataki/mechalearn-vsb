import 'package:flutter_test/flutter_test.dart';
import 'package:mechalearn_vsb/data/content_manifest.dart';
import 'package:mechalearn_vsb/data/courses.dart';
import 'package:mechalearn_vsb/models/user_progress.dart';
import 'package:mechalearn_vsb/services/content_integrity.dart';
import 'package:mechalearn_vsb/services/progress_service.dart';

/// PATCH v1.1.1: HMAC refuse-on-tamper is struck for offline v1.
/// content_version may be stamped on progress; integrity helpers remain for tooling.
void main() {
  test('content_version is defined for progress migrations', () {
    expect(ContentManifest.contentVersion, isNotEmpty);
    expect(ContentManifest.contentVersion, '1.1.0');
  });

  test('progress stamps content_version on award (no HMAC gate)', () {
    final math = courseById('matematika')!;
    final lessonId = math.units.first.lessons.first.id;
    final r = ProgressService.applyLessonAward(
      const UserProgress(),
      lessonId: lessonId,
      earnedXp: 10,
      now: DateTime(2026, 9, 14),
      course: math,
    );
    expect(r.progress.contentVersion, ContentManifest.contentVersion);
  });

  test('optional integrity helper still hashes curriculum (tooling only)', () {
    final hex = ContentIntegrity.computeHmacHex(allCourses);
    expect(hex.length, 64);
    // Not required to match manifest for app load (HMAC gate struck).
    expect(ContentIntegrity.canonicalPayload(allCourses).split('\n').length, 400);
  });
}
