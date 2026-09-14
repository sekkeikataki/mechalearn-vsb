import 'package:flutter_test/flutter_test.dart';
import 'package:mechalearn_vsb/data/courses.dart';
import 'package:mechalearn_vsb/models/user_progress.dart';
import 'package:mechalearn_vsb/services/progress_service.dart';

void main() {
  final math = courseById('matematika')!;
  final lessons = ProgressService.lessonPath(math);

  test('first lesson unlocked with empty progress', () {
    expect(
      ProgressService.canPlayLesson(lessons.first, const UserProgress(), math),
      isTrue,
    );
  });

  test('second lesson refused until first completed', () {
    expect(
      ProgressService.canPlayLesson(lessons[1], const UserProgress(), math),
      isFalse,
    );
    expect(
      ProgressService.canPlayLesson(
        lessons[1],
        UserProgress(completedLessons: {lessons.first}),
        math,
      ),
      isTrue,
    );
  });

  test('awardLesson refuse throws LessonLockedException', () {
    expect(
      () => ProgressService.applyLessonAward(
        const UserProgress(),
        lessonId: lessons[2],
        earnedXp: 50,
        course: math,
      ),
      throwsA(isA<LessonLockedException>()),
    );
  });

  test('assertCanPlayLesson throws typed LessonLockedException', () {
    expect(
      () => ProgressService.assertCanPlayLesson(
        lessons[2],
        const UserProgress(),
        math,
      ),
      throwsA(isA<LessonLockedException>()),
    );
  });

  test('completed lesson can be replayed', () {
    expect(
      ProgressService.canPlayLesson(
        lessons[2],
        UserProgress(completedLessons: {lessons[2]}),
        math,
      ),
      isTrue,
    );
  });

  test('all prior lessons required (not only immediate previous)', () {
    // lessons[0] missing, lessons[1] done → lessons[2] still locked.
    expect(
      ProgressService.canPlayLesson(
        lessons[2],
        UserProgress(completedLessons: {lessons[1]}),
        math,
      ),
      isFalse,
    );
    expect(
      ProgressService.canPlayLesson(
        lessons[2],
        UserProgress(completedLessons: {lessons[0], lessons[1]}),
        math,
      ),
      isTrue,
    );
  });

  test('unknown lesson refused', () {
    expect(
      ProgressService.canPlayLesson(
        'no_such_lesson',
        const UserProgress(),
        math,
      ),
      isFalse,
    );
  });
}
