import 'package:flutter_test/flutter_test.dart';
import 'package:mechalearn_vsb/models/exercise.dart';
import 'package:mechalearn_vsb/services/answer_checker.dart';

void main() {
  group('AnswerChecker.numeric', () {
    test('exact match', () {
      expect(AnswerChecker.checkNumeric(5, 5), isTrue);
    });

    test('within absolute tolerance', () {
      expect(AnswerChecker.checkNumeric(1.005, 1.0, tolerance: 0.01), isTrue);
      expect(AnswerChecker.checkNumeric(1.02, 1.0, tolerance: 0.01), isFalse);
    });

    test('comma-style via exercise', () {
      const ex = Exercise(
        id: 't',
        type: ExerciseType.numericFill,
        prompt: 'x',
        numericAnswer: 3.14,
        numericTolerance: 0.01,
      );
      expect(AnswerChecker.checkExercise(ex, '3,14'), isTrue);
      expect(AnswerChecker.checkExercise(ex, '3.15'), isTrue);
      expect(AnswerChecker.checkExercise(ex, '3.20'), isFalse);
    });
  });

  group('AnswerChecker.multipleChoice', () {
    test('index match', () {
      expect(AnswerChecker.checkMultipleChoice(2, 2), isTrue);
      expect(AnswerChecker.checkMultipleChoice(1, 2), isFalse);
    });
  });

  group('AnswerChecker.order', () {
    test('same order', () {
      expect(AnswerChecker.checkOrder([0, 1, 2], [0, 1, 2]), isTrue);
      expect(AnswerChecker.checkOrder([1, 0, 2], [0, 1, 2]), isFalse);
    });
  });

  group('AnswerChecker.trueFalse', () {
    test('with justification', () {
      const ex = Exercise(
        id: 'tf',
        type: ExerciseType.trueFalse,
        prompt: '?',
        trueFalseAnswer: true,
        justificationPrompt: 'Proč?',
        justificationOptions: ['A', 'B'],
        justificationCorrectIndex: 0,
      );
      expect(
        AnswerChecker.checkExercise(ex, {'value': true, 'justification': 0}),
        isTrue,
      );
      expect(
        AnswerChecker.checkExercise(ex, {'value': true, 'justification': 1}),
        isFalse,
      );
      expect(
        AnswerChecker.checkExercise(ex, {'value': false, 'justification': 0}),
        isFalse,
      );
    });
  });

  group('XP', () {
    test('xp amounts', () {
      const mc = Exercise(
        id: 'a',
        type: ExerciseType.multipleChoice,
        prompt: '',
        options: ['x'],
        correctIndex: 0,
      );
      const multi = Exercise(
        id: 'b',
        type: ExerciseType.multiStep,
        prompt: '',
        steps: [],
      );
      expect(AnswerChecker.xpForExercise(mc), 10);
      expect(AnswerChecker.xpForExercise(multi), 15);
      expect(AnswerChecker.xpForExercise(mc, perfect: false), 0);
    });
  });
}
