import 'unit.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final bool isPlaceholder;
  final List<Unit> units;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.isPlaceholder = false,
    this.units = const [],
  });
}
