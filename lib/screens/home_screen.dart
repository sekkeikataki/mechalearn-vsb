import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/courses.dart';
import '../models/lesson.dart';
import '../models/unit.dart';
import '../providers/progress_provider.dart';
import '../widgets/stat_chips.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);
    final todayXp = ref.watch(todayXpProvider).value ?? 0;

    return progressAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Chyba: $e'))),
      data: (progress) {
        final course =
            courseById(progress.activeCourseId ?? 'matematika') ??
                allCourses.first;
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('MechaLearn'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: StatChips(
                  xp: progress.xp,
                  streak: progress.streak,
                  hearts: progress.hearts,
                  heartsEnabled: progress.heartsEnabled,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _DailyGoalCard(
                todayXp: todayXp,
                goal: progress.dailyGoalXp,
              ),
              const SizedBox(height: 8),
              Text(
                course.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                course.isPlaceholder
                    ? 'Kurz zatím čeká na materiály od vyučujících.'
                    : 'Projdi jednotky shora dolů — odemkneš další lekci po dokončení předchozí.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (course.isPlaceholder)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Placeholder: obsah bude doplněn později.\n'
                      'Zvol Matematiku v záložce Kurzy.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ..._buildPath(context, course.units, progress.completedLessons),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildPath(
    BuildContext context,
    List<Unit> units,
    Set<String> completed,
  ) {
    final widgets = <Widget>[];
    var previousComplete = true;
    for (var u = 0; u < units.length; u++) {
      final unit = units[u];
      widgets.add(_UnitHeader(unit: unit, index: u + 1));
      for (var i = 0; i < unit.lessons.length; i++) {
        final lesson = unit.lessons[i];
        final done = completed.contains(lesson.id);
        final unlocked = previousComplete;
        widgets.add(
          _LessonNode(
            lesson: lesson,
            done: done,
            unlocked: unlocked,
            alignRight: i.isOdd,
            onTap: unlocked
                ? () => context.push('/lesson/${lesson.id}')
                : null,
          ),
        );
        previousComplete = done;
      }
    }
    return widgets;
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.todayXp, required this.goal});
  final int todayXp;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final p = (todayXp / goal).clamp(0.0, 1.0);
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dnešní cíl',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: p,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text('$todayXp / $goal XP'),
          ],
        ),
      ),
    );
  }
}

class _UnitHeader extends StatelessWidget {
  const _UnitHeader({required this.unit, required this.index});
  final Unit unit;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          Text(unit.iconEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jednotka $index',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(
                  unit.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    required this.lesson,
    required this.done,
    required this.unlocked,
    required this.alignRight,
    this.onTap,
  });

  final Lesson lesson;
  final bool done;
  final bool unlocked;
  final bool alignRight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg;
    IconData icon;
    if (done) {
      bg = cs.secondary;
      icon = Icons.check_rounded;
    } else if (unlocked) {
      bg = cs.primary;
      icon = Icons.play_arrow_rounded;
    } else {
      bg = cs.outlineVariant;
      icon = Icons.lock_outline;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: alignRight ? 72 : 8,
        right: alignRight ? 8 : 72,
        top: 6,
        bottom: 6,
      ),
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            width: 220,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bg.withValues(alpha: done || unlocked ? 0.15 : 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: bg, width: 2),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: bg,
                  foregroundColor: cs.onPrimary,
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lesson.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
