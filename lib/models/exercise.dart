enum ExerciseType {
  multipleChoice,
  numericFill,
  orderSteps,
  trueFalse,
  multiStep,
}

/// Základní cvičení v lekci.
class Exercise {
  final String id;
  final ExerciseType type;
  final String prompt;
  final String? explanation;
  final List<String>? options;
  final int? correctIndex;
  final double? numericAnswer;
  final double numericTolerance;
  final List<String>? orderItems;
  final List<int>? correctOrder;
  final bool? trueFalseAnswer;
  final String? justificationPrompt;
  final List<String>? justificationOptions;
  final int? justificationCorrectIndex;
  final List<MultiStepPart>? steps;
  final List<String>? hints;

  const Exercise({
    required this.id,
    required this.type,
    required this.prompt,
    this.explanation,
    this.options,
    this.correctIndex,
    this.numericAnswer,
    this.numericTolerance = 0.01,
    this.orderItems,
    this.correctOrder,
    this.trueFalseAnswer,
    this.justificationPrompt,
    this.justificationOptions,
    this.justificationCorrectIndex,
    this.steps,
    this.hints,
  });
}

class MultiStepPart {
  final String prompt;
  final ExerciseType type;
  final List<String>? options;
  final int? correctIndex;
  final double? numericAnswer;
  final double numericTolerance;
  final String? hint;

  const MultiStepPart({
    required this.prompt,
    required this.type,
    this.options,
    this.correctIndex,
    this.numericAnswer,
    this.numericTolerance = 0.01,
    this.hint,
  });
}
