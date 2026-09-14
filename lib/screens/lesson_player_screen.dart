import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/courses.dart';
import '../data/lesson_index.dart';
import '../models/exercise.dart';
import '../providers/progress_provider.dart';
import '../services/answer_checker.dart';
import '../services/content_integrity.dart';
import '../services/progress_service.dart';
import '../widgets/exercises/exercise_view.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  int _index = -1; // -1 = intro
  dynamic _currentAnswer;
  final List<Exercise> _gradedCorrect = [];
  String? _feedback;
  bool? _lastCorrect;

  @override
  Widget build(BuildContext context) {
    final lesson = findLesson(widget.lessonId);
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Lekce nenalezena')),
      );
    }

    final progressAsync = ref.watch(progressProvider);
    final progress = progressAsync.value;

    // Content integrity gate — refuse learning on HMAC mismatch.
    try {
      ContentIntegrity.verifyOrThrow(allCourses);
    } on ContentIntegrityException catch (e) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gpp_bad_outlined,
                    size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  e.message,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Zpět domů'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final catalog = progress == null
        ? null
        : (courseById(progress.activeCourseId ?? 'matematika') ??
            allCourses.first);

    // Engine unlock gate (defense in depth vs deep link / direct push).
    if (progress != null &&
        catalog != null &&
        !ProgressService.canPlayLesson(widget.lessonId, progress, catalog)) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock,
                    size: 48, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 16),
                Text(
                  'Lekce je zamčená',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nejdřív dokonči předchozí lekce na cestě.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Zpět domů'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final total = lesson.exercises.length;
    final inIntro = _index < 0;
    final finished = _index >= total;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (progress != null && progress.heartsEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 4),
                  Text('${progress.hearts}'),
                ],
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: inIntro
                ? 0
                : finished
                    ? 1
                    : (_index / total),
            minHeight: 6,
          ),
        ),
      ),
      body: finished
          ? _summary(lesson.xpReward)
          : inIntro
              ? _intro(lesson.intro)
              : _exercise(lesson.exercises[_index]),
    );
  }

  Widget _intro(String intro) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Úvod k lekci',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(intro, style: const TextStyle(height: 1.45, fontSize: 16)),
            ),
          ),
          FilledButton(
            onPressed: () => setState(() {
              _index = 0;
              _currentAnswer = null;
              _feedback = null;
            }),
            child: const Text('Spustit cvičení'),
          ),
        ],
      ),
    );
  }

  Widget _exercise(Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ExerciseView(
                key: ValueKey(exercise.id),
                exercise: exercise,
                onAnswerChanged: (a) => setState(() {
                  _currentAnswer = a;
                  _feedback = null;
                  _lastCorrect = null;
                }),
              ),
            ),
          ),
          if (_feedback != null) ...[
            const SizedBox(height: 8),
            Material(
              color: (_lastCorrect == true)
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _feedback!,
                  style: TextStyle(
                    color: _lastCorrect == true
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_lastCorrect == true)
            FilledButton(
              onPressed: _next,
              child: const Text('Pokračovat'),
            )
          else
            FilledButton(
              onPressed: _currentAnswer == null ? null : () => _check(exercise),
              child: const Text('Zkontrolovat'),
            ),
        ],
      ),
    );
  }

  Future<void> _check(Exercise exercise) async {
    final progress = ref.read(progressProvider).value;
    if (progress == null) return;
    final catalog =
        courseById(progress.activeCourseId ?? 'matematika') ?? allCourses.first;

    try {
      ContentIntegrity.verifyOrThrow(allCourses);
    } on ContentIntegrityException catch (e) {
      setState(() {
        _lastCorrect = false;
        _feedback = e.message;
      });
      return;
    }

    if (!ProgressService.canPlayLesson(widget.lessonId, progress, catalog)) {
      setState(() {
        _lastCorrect = false;
        _feedback = 'Lekce je zamčená';
      });
      return;
    }

    // order: if never reordered, emit current order
    var answer = _currentAnswer;
    if (exercise.type == ExerciseType.orderSteps && answer == null) {
      answer = List<int>.generate(exercise.orderItems!.length, (i) => i);
    }
    if (exercise.type == ExerciseType.trueFalse) {
      if (answer is Map && answer['value'] == null) return;
      if (answer is! Map && answer == null) return;
      if (exercise.justificationPrompt != null) {
        if (answer is! Map || answer['justification'] == null) return;
      }
    }

    // Sole grader — AnswerChecker.
    final ok = AnswerChecker.checkExercise(exercise, answer);
    if (ok) {
      final xp = AnswerChecker.xpForExercise(exercise);
      setState(() {
        _lastCorrect = true;
        if (!_gradedCorrect.any((e) => e.id == exercise.id)) {
          _gradedCorrect.add(exercise);
        }
        _feedback = 'Správně! +$xp XP\n${exercise.explanation ?? ''}';
      });
    } else {
      final canContinue =
          await ref.read(progressProvider.notifier).loseHeart();
      setState(() {
        _lastCorrect = false;
        _feedback =
            'Zatím ne. ${exercise.explanation ?? 'Zkus to znovu.'}';
      });
      if (!canContinue && mounted) {
        final p = ref.read(progressProvider).value;
        if (p != null && p.heartsEnabled && p.hearts <= 0) {
          await showDialog<void>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Došly životy'),
              content: const Text(
                'Doplň životy v nastavení, nebo je vypni pro volný režim.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  void _next() {
    setState(() {
      _index++;
      _currentAnswer = null;
      _feedback = null;
      _lastCorrect = null;
    });
  }

  Widget _summary(int bonus) {
    final totalXp = AnswerChecker.xpForLesson(
      _gradedCorrect,
      completionBonus: _gradedCorrect.isNotEmpty ? bonus : 0,
    );
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Icon(Icons.emoji_events, size: 72,
              color: Theme.of(context).colorScheme.tertiary),
          const SizedBox(height: 16),
          Text(
            'Lekce hotová!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Správně: ${_gradedCorrect.length}\nZískáno XP: $totalXp',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          FilledButton(
            onPressed: () async {
              await ref.read(progressProvider.notifier).awardLesson(
                    lessonId: widget.lessonId,
                    gradedCorrect: List<Exercise>.from(_gradedCorrect),
                    completionBonus:
                        _gradedCorrect.isNotEmpty ? bonus : 0,
                  );
              if (mounted) context.pop();
            },
            child: const Text('Hotovo'),
          ),
        ],
      ),
    );
  }
}
