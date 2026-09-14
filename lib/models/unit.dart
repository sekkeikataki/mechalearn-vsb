import 'lesson.dart';

class Unit {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final List<Lesson> lessons;

  const Unit({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.lessons,
  });
}
