import 'exercise.dart';

class Lesson {
  final String id;
  final String title;
  final String intro;
  final List<Exercise> exercises;
  final int xpReward;

  const Lesson({
    required this.id,
    required this.title,
    required this.intro,
    required this.exercises,
    this.xpReward = 20,
  });
}
