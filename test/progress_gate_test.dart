import 'package:flutter_test/flutter_test.dart';
import 'package:mechalearn_vsb/data/courses.dart';
import 'package:mechalearn_vsb/models/exercise.dart';
import 'package:mechalearn_vsb/models/user_progress.dart';
import 'package:mechalearn_vsb/services/answer_checker.dart';
import 'package:mechalearn_vsb/services/progress_service.dart';

void main() {
  final maths = courseById('matematika')!;
  final firstId = maths.units.first.lessons.first.id; // m1_l1
  final secondId = maths.units.first.lessons[1].id; // m1_l2
  final thirdId = maths.units.first.lessons[2].id; // m1_l3

  group('Unlock refuse (engine gate)', () {
    test('first lesson unlocked with empty progress', () {
      expect(
        ProgressService.canStartLesson(firstId, {}),
        isTrue,
      );
    });

    test('second lesson refused until first completed', () {
      expect(
        ProgressService.canStartLesson(secondId, {}),
        isFalse,
      );
      expect(
        () => ProgressService.assertCanStartLesson(secondId, {}),
        throwsA(isA<LessonLockedException>()),
      );
    });

    test('second lesson allowed after first completed', () {
      expect(
        ProgressService.canStartLesson(secondId, {firstId}),
        isTrue,
      );
    });

    test('completed locked-path lesson can be replayed', () {
      // third completed even if somehow out of path — replay allowed
      expect(
        ProgressService.canStartLesson(thirdId, {thirdId}),
        isTrue,
      );
    });

    test('canPlayLesson mirrors canStartLesson with UserProgress', () {
      const locked = UserProgress();
      expect(ProgressService.canPlayLesson(secondId, locked, maths), isFalse);
      final unlocked = locked.copyWith(completedLessons: {firstId});
      expect(ProgressService.canPlayLesson(secondId, unlocked, maths), isTrue);
    });

    test('award on locked lesson throws LessonLockedException', () {
      const p = UserProgress();
      expect(
        () => ProgressService.applyLessonAward(
          p,
          lessonId: secondId,
          earnedXp: 50,
        ),
        throwsA(isA<LessonLockedException>()),
      );
    });
  });

  group('XP best-of / no replay farm', () {
    const mc = Exercise(
      id: 'e1',
      type: ExerciseType.multipleChoice,
      prompt: '',
      options: ['a'],
      correctIndex: 0,
    );

    test('first finish awards full xpForLesson', () {
      final earned = AnswerChecker.xpForLesson([mc], completionBonus: 20);
      expect(earned, 30); // 10 + 20
      const p = UserProgress();
      // unlock first lesson
      final result = ProgressService.applyLessonAward(
        p,
        lessonId: firstId,
        earnedXp: earned,
        now: DateTime(2026, 9, 14),
      );
      expect(result.xpDelta, 30);
      expect(result.progress.xp, 30);
      expect(result.progress.lessonBestXp[firstId], 30);
      expect(result.progress.completedLessons, contains(firstId));
    });

    test('replay with same score adds zero XP', () {
      var p = const UserProgress(completedLessons: {}, xp: 0);
      final earned = AnswerChecker.xpForLesson([mc], completionBonus: 20);
      final first = ProgressService.applyLessonAward(
        p,
        lessonId: firstId,
        earnedXp: earned,
        now: DateTime(2026, 9, 14),
      );
      p = first.progress;
      final replay = ProgressService.applyLessonAward(
        p,
        lessonId: firstId,
        earnedXp: earned,
        now: DateTime(2026, 9, 14),
      );
      expect(replay.xpDelta, 0);
      expect(replay.progress.xp, first.progress.xp);
      expect(replay.progress.lessonBestXp[firstId], earned);
    });

    test('replay with lower score does not decrease or farm', () {
      final high = AnswerChecker.xpForLesson([mc, mc], completionBonus: 20);
      final low = AnswerChecker.xpForLesson([mc], completionBonus: 20);
      var p = const UserProgress();
      final first = ProgressService.applyLessonAward(
        p,
        lessonId: firstId,
        earnedXp: high,
        now: DateTime(2026, 9, 14),
      );
      final replay = ProgressService.applyLessonAward(
        first.progress,
        lessonId: firstId,
        earnedXp: low,
        now: DateTime(2026, 9, 14),
      );
      expect(replay.xpDelta, 0);
      expect(replay.progress.xp, first.progress.xp);
      expect(replay.progress.lessonBestXp[firstId], high);
    });

    test('replay with higher score awards only delta', () {
      final low = AnswerChecker.xpForLesson([mc], completionBonus: 20); // 30
      final high = AnswerChecker.xpForLesson([mc, mc], completionBonus: 20); // 40
      final first = ProgressService.applyLessonAward(
        const UserProgress(),
        lessonId: firstId,
        earnedXp: low,
        now: DateTime(2026, 9, 14),
      );
      final improved = ProgressService.applyLessonAward(
        first.progress,
        lessonId: firstId,
        earnedXp: high,
        now: DateTime(2026, 9, 14),
      );
      expect(improved.xpDelta, high - low);
      expect(improved.progress.xp, high);
      expect(improved.progress.lessonBestXp[firstId], high);
    });
  });
}
