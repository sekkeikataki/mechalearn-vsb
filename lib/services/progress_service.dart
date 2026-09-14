import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/content_manifest.dart';
import '../data/courses.dart';
import '../models/course.dart';
import '../models/user_progress.dart';

/// Typed refuse when a lesson is locked by prerequisite path.
class LessonLockedException implements Exception {
  LessonLockedException(this.lessonId, [this.message]);

  final String lessonId;
  final String? message;

  @override
  String toString() =>
      message ?? 'Lekce $lessonId je zamčená — nesplněný předpoklad';
}

class ProgressService {
  static const _key = 'mechalearn_progress_v1';

  Future<UserProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const UserProgress();
    try {
      // Keep progress even if contentVersion differs from current manifest;
      // never remap / drop completed IDs on version skew.
      return UserProgress.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const UserProgress();
    }
  }

  Future<void> save(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(progress.toJson()));
  }

  /// Study-day = yyyy-MM-dd z zařízení.
  ///
  /// Streak rules (anti clock-jump farm):
  /// - At most +1 streak per real calendar advance (diff == 1).
  /// - Same calendar day → no change.
  /// - Gap / jump forward (diff > 1) → reset streak to 1 (no multi-day farm).
  /// - Clock set backward (diff < 0) → ignore (keep streak + lastStudyDate).
  static UserProgress applyStreak(UserProgress p, DateTime now) {
    final today = dateKey(now);
    if (p.lastStudyDate == null || p.lastStudyDate!.isEmpty) {
      return p.copyWith(streak: 1, lastStudyDate: today);
    }
    if (p.lastStudyDate == today) return p;

    final last = DateTime.tryParse(p.lastStudyDate!);
    if (last == null) {
      return p.copyWith(streak: 1, lastStudyDate: today);
    }

    final lastDay = DateTime(last.year, last.month, last.day);
    final todayDay = DateTime(now.year, now.month, now.day);
    final diff = todayDay.difference(lastDay).inDays;

    if (diff < 0) {
      // Hodiny posunuté dozadu — neaktualizovat streak ani lastStudyDate.
      return p;
    }
    if (diff == 1) {
      // Maximálně +1 za kalendářní den.
      return p.copyWith(streak: p.streak + 1, lastStudyDate: today);
    }
    // diff > 1: mezera nebo skok hodin vpřed bez mezilehlého open → žádný farm.
    return p.copyWith(streak: 1, lastStudyDate: today);
  }

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Flat ordered lesson path for a course (units then lessons in order).
  static List<String> lessonPath(Course catalog) {
    return [
      for (final unit in catalog.units)
        for (final lesson in unit.lessons) lesson.id,
    ];
  }

  /// Engine gate matching skill-path UX:
  /// playable iff every prior lesson in the course path is completed.
  /// First lesson is always playable. Completed lessons remain playable (replay).
  static bool canPlayLesson(
    String lessonId,
    UserProgress progress,
    Course catalog,
  ) {
    if (catalog.isPlaceholder || catalog.units.isEmpty) return false;

    final path = lessonPath(catalog);
    final idx = path.indexOf(lessonId);
    if (idx < 0) return false;

    if (progress.completedLessons.contains(lessonId)) return true;
    if (idx == 0) return true;

    for (var i = 0; i < idx; i++) {
      if (!progress.completedLessons.contains(path[i])) return false;
    }
    return true;
  }

  /// Backward-compatible helper used by older call sites.
  static bool canStartLesson(
    String lessonId,
    Set<String> completed, {
    Course? course,
    String? courseId,
  }) {
    final c = course ??
        courseById(courseId ?? 'matematika') ??
        courseById('matematika');
    if (c == null) return false;
    return canPlayLesson(
      lessonId,
      UserProgress(completedLessons: completed, activeCourseId: c.id),
      c,
    );
  }

  /// Odmítne start zamčené lekce — volej před spuštěním playeru / award.
  static void assertCanPlayLesson(
    String lessonId,
    UserProgress progress,
    Course catalog,
  ) {
    if (!canPlayLesson(lessonId, progress, catalog)) {
      throw LessonLockedException(
        lessonId,
        'Lekce $lessonId je zamčená — nesplněný předpoklad',
      );
    }
  }

  static void assertCanStartLesson(
    String lessonId,
    Set<String> completed, {
    Course? course,
    String? courseId,
  }) {
    final c = course ??
        courseById(courseId ?? 'matematika') ??
        courseById('matematika');
    if (c == null ||
        !canStartLesson(lessonId, completed, course: c, courseId: courseId)) {
      throw LessonLockedException(
        lessonId,
        'Lekce $lessonId je zamčená — nesplněný předpoklad',
      );
    }
  }

  /// Best-of XP award: total XP rises only by max(0, earnedXp − prevBest).
  /// Never farms full run XP on lesson replay.
  /// Returns `(progress, xpDelta)` where [xpDelta] is what to add to today XP.
  static ({UserProgress progress, int xpDelta}) applyLessonAward(
    UserProgress p, {
    required String lessonId,
    required int earnedXp,
    DateTime? now,
    Course? course,
    String? courseId,
  }) {
    final catalog = course ??
        courseById(courseId ?? p.activeCourseId ?? 'matematika') ??
        courseById('matematika');
    if (catalog == null) {
      throw LessonLockedException(lessonId, 'Kurz nenalezen');
    }
    assertCanPlayLesson(lessonId, p, catalog);

    var next = applyStreak(p, now ?? DateTime.now());
    final completed = {...next.completedLessons, lessonId};
    final best = Map<String, int>.from(next.lessonBestXp);
    final prev = best[lessonId] ?? 0;
    final delta = earnedXp > prev ? earnedXp - prev : 0;
    if (earnedXp > prev) best[lessonId] = earnedXp;

    return (
      progress: next.copyWith(
        xp: next.xp + delta,
        completedLessons: completed,
        lessonBestXp: best,
        contentVersion: ContentManifest.contentVersion,
      ),
      xpDelta: delta,
    );
  }

  Future<int> loadTodayXp() async {
    final prefs = await SharedPreferences.getInstance();
    final today = dateKey(DateTime.now());
    final storedDay = prefs.getString('today_xp_day');
    if (storedDay != today) return 0;
    return prefs.getInt('today_xp') ?? 0;
  }

  Future<void> addTodayXp(int amount) async {
    if (amount <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final today = dateKey(DateTime.now());
    final storedDay = prefs.getString('today_xp_day');
    final current = storedDay == today ? (prefs.getInt('today_xp') ?? 0) : 0;
    await prefs.setString('today_xp_day', today);
    await prefs.setInt('today_xp', current + amount);
  }
}
