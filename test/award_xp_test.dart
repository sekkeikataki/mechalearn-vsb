import 'package:flutter_test/flutter_test.dart';
import 'package:mechalearn_vsb/data/courses.dart';
import 'package:mechalearn_vsb/models/user_progress.dart';
import 'package:mechalearn_vsb/services/progress_service.dart';

void main() {
  final math = courseById('matematika')!;
  final lessonId = math.units.first.lessons.first.id;
  final now = DateTime(2026, 9, 14);

  test('first award with XP X increases total by X', () {
    const p = UserProgress();
    final r = ProgressService.applyLessonAward(
      p,
      lessonId: lessonId,
      earnedXp: 100,
      now: now,
      course: math,
    );
    expect(r.xpDelta, 100);
    expect(r.progress.xp, 100);
    expect(r.progress.lessonBestXp[lessonId], 100);
    expect(r.progress.completedLessons.contains(lessonId), isTrue);
  });

  test('second award with same XP increases total by 0', () {
    var p = const UserProgress();
    p = ProgressService.applyLessonAward(
      p,
      lessonId: lessonId,
      earnedXp: 100,
      now: now,
      course: math,
    ).progress;

    final r = ProgressService.applyLessonAward(
      p,
      lessonId: lessonId,
      earnedXp: 100,
      now: now,
      course: math,
    );
    expect(r.xpDelta, 0);
    expect(r.progress.xp, 100);
    expect(r.progress.lessonBestXp[lessonId], 100);
  });

  test('second award with lower XP increases total by 0', () {
    var p = const UserProgress();
    p = ProgressService.applyLessonAward(
      p,
      lessonId: lessonId,
      earnedXp: 100,
      now: now,
      course: math,
    ).progress;

    final r = ProgressService.applyLessonAward(
      p,
      lessonId: lessonId,
      earnedXp: 40,
      now: now,
      course: math,
    );
    expect(r.xpDelta, 0);
    expect(r.progress.xp, 100);
    expect(r.progress.lessonBestXp[lessonId], 100);
  });

  test('second award with higher XP increases by new-old only', () {
    var p = const UserProgress();
    p = ProgressService.applyLessonAward(
      p,
      lessonId: lessonId,
      earnedXp: 100,
      now: now,
      course: math,
    ).progress;

    final r = ProgressService.applyLessonAward(
      p,
      lessonId: lessonId,
      earnedXp: 130,
      now: now,
      course: math,
    );
    expect(r.xpDelta, 30);
    expect(r.progress.xp, 130);
    expect(r.progress.lessonBestXp[lessonId], 130);
  });
}
