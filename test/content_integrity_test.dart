import 'package:flutter_test/flutter_test.dart';
import 'package:mechalearn_vsb/data/content_manifest.dart';
import 'package:mechalearn_vsb/data/courses.dart';
import 'package:mechalearn_vsb/models/course.dart';
import 'package:mechalearn_vsb/models/exercise.dart';
import 'package:mechalearn_vsb/models/lesson.dart';
import 'package:mechalearn_vsb/models/unit.dart';
import 'package:mechalearn_vsb/services/content_integrity.dart';

void main() {
  test('shipped curriculum HMAC matches manifest', () {
    expect(ContentIntegrity.verify(allCourses), isTrue);
    expect(
      ContentIntegrity.computeHmacHex(allCourses),
      ContentManifest.contentHmacHex,
    );
    expect(ContentManifest.contentVersion, isNotEmpty);
    expect(ContentManifest.hmacAlgorithm, 'HmacSHA256');
  });

  test('HMAC mismatch refuse with Czech message', () {
    final tampered = [
      Course(
        id: 'matematika',
        title: 'T',
        description: 'd',
        iconEmoji: 'x',
        units: [
          Unit(
            id: 'u',
            title: 'U',
            description: 'd',
            iconEmoji: 'x',
            lessons: [
              Lesson(
                id: 'l1',
                title: 'L',
                intro: 'i',
                exercises: [
                  const Exercise(
                    id: 'e1',
                    type: ExerciseType.numericFill,
                    prompt: '1+1',
                    numericAnswer: 999,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ];

    expect(ContentIntegrity.verify(tampered), isFalse);
    expect(
      () => ContentIntegrity.verifyOrThrow(tampered),
      throwsA(
        isA<ContentIntegrityException>().having(
          (e) => e.message,
          'message',
          contains('Kontrola integrity obsahu selhala'),
        ),
      ),
    );
  });

  test('canonical / signed payload is stable and ordered', () {
    final payload = ContentIntegrity.canonicalPayload(allCourses);
    expect(payload.isNotEmpty, isTrue);
    final lines = payload.split('\n');
    expect(lines.length, 400);
    expect(lines.first.startsWith('matematika|'), isTrue);
    expect(
      ContentIntegrity.signedPayload(allCourses),
      startsWith('content_version=${ContentManifest.contentVersion}\n'),
    );
  });
}
