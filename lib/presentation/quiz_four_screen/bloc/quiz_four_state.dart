part of 'quiz_four_bloc.dart';

/// Represents the state of QuizFour in the application.

// ignore_for_file: must_be_immutable
class QuizFourState extends Equatable {
  QuizFourState({
    this.quizFourModelObj,
    this.hasSelection = false,
  });

  QuizFourModel? quizFourModelObj;
  final bool hasSelection;

  @override
  List<Object?> get props => [quizFourModelObj, hasSelection];

  QuizFourState copyWith({
    QuizFourModel? quizFourModelObj,
    bool? hasSelection,
  }) {
    return QuizFourState(
      quizFourModelObj: quizFourModelObj ?? this.quizFourModelObj,
      hasSelection: hasSelection ?? this.hasSelection,
    );
  }
}
