import '../models/exercise.dart';

/// Kontrola odpovědí — numerické s tolerancí, MCQ, pořadí, ano/ne.
class AnswerChecker {
  /// Porovná numerickou odpověď s absolutní tolerancí.
  static bool checkNumeric(
    double userAnswer,
    double correct, {
    double tolerance = 0.01,
  }) {
    final absTol = tolerance.abs();
    return (userAnswer - correct).abs() <= absTol + 1e-12;
  }

  static bool checkMultipleChoice(int selected, int correct) =>
      selected == correct;

  static bool checkOrder(List<int> userOrder, List<int> correctOrder) {
    if (userOrder.length != correctOrder.length) return false;
    for (var i = 0; i < userOrder.length; i++) {
      if (userOrder[i] != correctOrder[i]) return false;
    }
    return true;
  }

  static bool checkTrueFalse(bool answer, bool correct) => answer == correct;

  /// Vyhodnotí celé cvičení podle typu.
  static bool checkExercise(Exercise exercise, dynamic answer) {
    switch (exercise.type) {
      case ExerciseType.multipleChoice:
        return checkMultipleChoice(answer as int, exercise.correctIndex!);
      case ExerciseType.numericFill:
        final v = answer is double
            ? answer
            : double.tryParse(answer.toString().replaceAll(',', '.'));
        if (v == null) return false;
        return checkNumeric(v, exercise.numericAnswer!,
            tolerance: exercise.numericTolerance);
      case ExerciseType.orderSteps:
        return checkOrder(
          List<int>.from(answer as List),
          exercise.correctOrder!,
        );
      case ExerciseType.trueFalse:
        if (answer is Map) {
          final tf = answer['value'] as bool;
          final just = answer['justification'] as int?;
          final okTf = checkTrueFalse(tf, exercise.trueFalseAnswer!);
          if (exercise.justificationCorrectIndex == null) return okTf;
          return okTf && just == exercise.justificationCorrectIndex;
        }
        return checkTrueFalse(answer as bool, exercise.trueFalseAnswer!);
      case ExerciseType.multiStep:
        final answers = answer as List;
        final steps = exercise.steps!;
        if (answers.length != steps.length) return false;
        for (var i = 0; i < steps.length; i++) {
          if (!_checkPart(steps[i], answers[i])) return false;
        }
        return true;
    }
  }

  static bool _checkPart(MultiStepPart part, dynamic answer) {
    switch (part.type) {
      case ExerciseType.multipleChoice:
        return checkMultipleChoice(answer as int, part.correctIndex!);
      case ExerciseType.numericFill:
        final v = answer is double
            ? answer
            : double.tryParse(answer.toString().replaceAll(',', '.'));
        if (v == null) return false;
        return checkNumeric(v, part.numericAnswer!,
            tolerance: part.numericTolerance);
      case ExerciseType.trueFalse:
        return checkTrueFalse(answer as bool, part.correctIndex == 1);
      default:
        return false;
    }
  }

  /// XP za správnou odpověď (základ 10, multi-step 15).
  static int xpForExercise(Exercise exercise, {bool perfect = true}) {
    if (!perfect) return 0;
    switch (exercise.type) {
      case ExerciseType.multiStep:
        return 15;
      case ExerciseType.orderSteps:
        return 12;
      default:
        return 10;
    }
  }
}
