import 'package:flutter_test/flutter_test.dart';
import 'package:mechalearn_vsb/data/courses.dart';
import 'package:mechalearn_vsb/models/exercise.dart';

void main() {
  test('matematika course is fully populated', () {
    final math = courseById('matematika')!;
    expect(math.isPlaceholder, isFalse);
    expect(math.units.length, 8);
    for (final u in math.units) {
      expect(u.lessons.length, greaterThanOrEqualTo(4));
      for (final l in u.lessons) {
        expect(l.exercises.length, greaterThanOrEqualTo(8));
        expect(l.intro.isNotEmpty, isTrue);
        for (final e in l.exercises) {
          expect(e.prompt.isNotEmpty, isTrue);
          switch (e.type) {
            case ExerciseType.multipleChoice:
              expect(e.options, isNotNull);
              expect(e.correctIndex, isNotNull);
            case ExerciseType.numericFill:
              expect(e.numericAnswer, isNotNull);
            case ExerciseType.orderSteps:
              expect(e.orderItems, isNotNull);
              expect(e.correctOrder, isNotNull);
            case ExerciseType.trueFalse:
              expect(e.trueFalseAnswer, isNotNull);
            case ExerciseType.multiStep:
              expect(e.steps, isNotNull);
              expect(e.steps!.length, greaterThanOrEqualTo(2));
          }
        }
      }
    }
  });

  test('placeholder courses exist', () {
    final placeholders =
        allCourses.where((c) => c.isPlaceholder).map((c) => c.id).toSet();
    expect(
      placeholders,
      containsAll([
        'fyzika',
        'elektronika',
        'mechanika',
        'rizeni',
        'programovani',
      ]),
    );
  });

  test('sample maths answers sanity', () {
    final math = courseById('matematika')!;
    final l1 = math.units.first.lessons.first;
    final numeric = l1.exercises.firstWhere(
      (e) => e.type == ExerciseType.numericFill,
    );
    // (−8)·(−3) = 24
    expect(numeric.numericAnswer, 24);
  });
}
