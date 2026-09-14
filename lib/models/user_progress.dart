class UserProgress {
  final bool onboarded;
  final int dailyGoalXp;
  final int xp;
  final int streak;
  final String? lastStudyDate; // yyyy-MM-dd
  final int hearts;
  final bool heartsEnabled;
  final int heartsMax;
  final Set<String> completedLessons;
  final String? activeCourseId;
  final Map<String, int> lessonBestXp;

  const UserProgress({
    this.onboarded = false,
    this.dailyGoalXp = 30,
    this.xp = 0,
    this.streak = 0,
    this.lastStudyDate,
    this.hearts = 5,
    this.heartsEnabled = true,
    this.heartsMax = 5,
    this.completedLessons = const {},
    this.activeCourseId = 'matematika',
    this.lessonBestXp = const {},
  });

  UserProgress copyWith({
    bool? onboarded,
    int? dailyGoalXp,
    int? xp,
    int? streak,
    String? lastStudyDate,
    int? hearts,
    bool? heartsEnabled,
    int? heartsMax,
    Set<String>? completedLessons,
    String? activeCourseId,
    Map<String, int>? lessonBestXp,
  }) {
    return UserProgress(
      onboarded: onboarded ?? this.onboarded,
      dailyGoalXp: dailyGoalXp ?? this.dailyGoalXp,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      hearts: hearts ?? this.hearts,
      heartsEnabled: heartsEnabled ?? this.heartsEnabled,
      heartsMax: heartsMax ?? this.heartsMax,
      completedLessons: completedLessons ?? this.completedLessons,
      activeCourseId: activeCourseId ?? this.activeCourseId,
      lessonBestXp: lessonBestXp ?? this.lessonBestXp,
    );
  }

  Map<String, dynamic> toJson() => {
        'onboarded': onboarded,
        'dailyGoalXp': dailyGoalXp,
        'xp': xp,
        'streak': streak,
        'lastStudyDate': lastStudyDate,
        'hearts': hearts,
        'heartsEnabled': heartsEnabled,
        'heartsMax': heartsMax,
        'completedLessons': completedLessons.toList(),
        'activeCourseId': activeCourseId,
        'lessonBestXp': lessonBestXp,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      onboarded: json['onboarded'] as bool? ?? false,
      dailyGoalXp: json['dailyGoalXp'] as int? ?? 30,
      xp: json['xp'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      lastStudyDate: json['lastStudyDate'] as String?,
      hearts: json['hearts'] as int? ?? 5,
      heartsEnabled: json['heartsEnabled'] as bool? ?? true,
      heartsMax: json['heartsMax'] as int? ?? 5,
      completedLessons: Set<String>.from(
        (json['completedLessons'] as List?)?.cast<String>() ?? const [],
      ),
      activeCourseId: json['activeCourseId'] as String? ?? 'matematika',
      lessonBestXp: Map<String, int>.from(
        (json['lessonBestXp'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), (v as num).toInt()),
            ) ??
            {},
      ),
    );
  }
}
