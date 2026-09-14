import 'package:flutter_test/flutter_test.dart';
import 'package:mechalearn_vsb/models/user_progress.dart';
import 'package:mechalearn_vsb/services/progress_service.dart';

void main() {
  group('Streak', () {
    test('first study day sets streak to 1', () {
      const p = UserProgress();
      final n = ProgressService.applyStreak(p, DateTime(2026, 9, 14));
      expect(n.streak, 1);
      expect(n.lastStudyDate, '2026-09-14');
    });

    test('same day does not increase streak', () {
      const p = UserProgress(streak: 3, lastStudyDate: '2026-09-14');
      final n = ProgressService.applyStreak(p, DateTime(2026, 9, 14));
      expect(n.streak, 3);
    });

    test('consecutive day increments by at most 1', () {
      const p = UserProgress(streak: 3, lastStudyDate: '2026-09-13');
      final n = ProgressService.applyStreak(p, DateTime(2026, 9, 14));
      expect(n.streak, 4);
      expect(n.lastStudyDate, '2026-09-14');
    });

    test('gap / forward jump resets to 1 (no farm)', () {
      const p = UserProgress(streak: 10, lastStudyDate: '2026-09-10');
      final n = ProgressService.applyStreak(p, DateTime(2026, 9, 14));
      expect(n.streak, 1);
      expect(n.lastStudyDate, '2026-09-14');
    });

    test('clock set backward ignores streak update', () {
      const p = UserProgress(streak: 5, lastStudyDate: '2026-09-14');
      final n = ProgressService.applyStreak(p, DateTime(2026, 9, 10));
      expect(n.streak, 5);
      expect(n.lastStudyDate, '2026-09-14');
    });

    test('multi-day clock jump forward does not farm streak', () {
      const p = UserProgress(streak: 5, lastStudyDate: '2026-09-10');
      final n = ProgressService.applyStreak(p, DateTime(2026, 9, 15));
      expect(n.streak, 1);
      expect(n.lastStudyDate, '2026-09-15');
    });
  });

  test('UserProgress json roundtrip', () {
    const p = UserProgress(
      onboarded: true,
      xp: 120,
      streak: 4,
      completedLessons: {'m1_l1'},
      heartsEnabled: false,
      lessonBestXp: {'m1_l1': 50},
      contentVersion: '1.1.0',
    );
    final back = UserProgress.fromJson(p.toJson());
    expect(back.xp, 120);
    expect(back.streak, 4);
    expect(back.completedLessons, {'m1_l1'});
    expect(back.heartsEnabled, false);
    expect(back.lessonBestXp['m1_l1'], 50);
    expect(back.contentVersion, '1.1.0');
  });
}
