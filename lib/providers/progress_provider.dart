import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress.dart';
import '../services/progress_service.dart';

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

final progressProvider =
    AsyncNotifierProvider<ProgressNotifier, UserProgress>(ProgressNotifier.new);

final todayXpProvider = FutureProvider<int>((ref) async {
  ref.watch(progressProvider);
  return ref.read(progressServiceProvider).loadTodayXp();
});

class ProgressNotifier extends AsyncNotifier<UserProgress> {
  ProgressService get _service => ref.read(progressServiceProvider);

  @override
  Future<UserProgress> build() => _service.load();

  Future<void> _persist(UserProgress p) async {
    state = AsyncData(p);
    await _service.save(p);
  }

  Future<void> completeOnboarding(int dailyGoalXp) async {
    final p = state.value ?? const UserProgress();
    await _persist(p.copyWith(onboarded: true, dailyGoalXp: dailyGoalXp));
  }

  Future<void> setHeartsEnabled(bool enabled) async {
    final p = state.value ?? const UserProgress();
    await _persist(p.copyWith(heartsEnabled: enabled));
  }

  Future<void> setActiveCourse(String id) async {
    final p = state.value ?? const UserProgress();
    await _persist(p.copyWith(activeCourseId: id));
  }

  Future<void> setDailyGoal(int xp) async {
    final p = state.value ?? const UserProgress();
    await _persist(p.copyWith(dailyGoalXp: xp));
  }

  Future<bool> loseHeart() async {
    final p = state.value ?? const UserProgress();
    if (!p.heartsEnabled) return true;
    if (p.hearts <= 0) return false;
    await _persist(p.copyWith(hearts: p.hearts - 1));
    return true;
  }

  Future<void> refillHearts() async {
    final p = state.value ?? const UserProgress();
    await _persist(p.copyWith(hearts: p.heartsMax));
  }

  Future<void> awardLesson({
    required String lessonId,
    required int earnedXp,
  }) async {
    var p = state.value ?? const UserProgress();
    p = ProgressService.applyStreak(p, DateTime.now());
    final completed = {...p.completedLessons, lessonId};
    final best = Map<String, int>.from(p.lessonBestXp);
    final prev = best[lessonId] ?? 0;
    if (earnedXp > prev) best[lessonId] = earnedXp;
    await _service.addTodayXp(earnedXp);
    await _persist(
      p.copyWith(
        xp: p.xp + earnedXp,
        completedLessons: completed,
        lessonBestXp: best,
      ),
    );
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mechalearn_progress_v1');
    await prefs.remove('today_xp');
    await prefs.remove('today_xp_day');
    state = const AsyncData(UserProgress());
  }
}
