import '../models/lesson.dart';
import 'courses.dart';

Lesson? findLesson(String id) {
  for (final course in allCourses) {
    for (final unit in course.units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == id) return lesson;
      }
    }
  }
  return null;
}
