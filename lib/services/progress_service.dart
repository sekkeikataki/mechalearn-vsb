import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress.dart';

class ProgressService {
  static const _key = 'mechalearn_progress_v1';

  Future<UserProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const UserProgress();
    try {
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

  /// Aktualizace streaku podle dnešního data (lokální).
  static UserProgress applyStreak(UserProgress p, DateTime now) {
    final today = _dateKey(now);
    final yesterday = _dateKey(now.subtract(const Duration(days: 1)));
    if (p.lastStudyDate == today) return p;
    if (p.lastStudyDate == yesterday) {
      return p.copyWith(streak: p.streak + 1, lastStudyDate: today);
    }
    return p.copyWith(streak: 1, lastStudyDate: today);
  }

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// XP získané dnes (jednoduchá aproximace: pokud lastStudyDate == today, vrátí 0
  /// a denní cíl se sleduje přes session — pro offline v1 ukládáme denní XP zvlášť).
  Future<int> loadTodayXp() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final storedDay = prefs.getString('today_xp_day');
    if (storedDay != today) return 0;
    return prefs.getInt('today_xp') ?? 0;
  }

  Future<void> addTodayXp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final storedDay = prefs.getString('today_xp_day');
    final current = storedDay == today ? (prefs.getInt('today_xp') ?? 0) : 0;
    await prefs.setString('today_xp_day', today);
    await prefs.setInt('today_xp', current + amount);
  }
}
