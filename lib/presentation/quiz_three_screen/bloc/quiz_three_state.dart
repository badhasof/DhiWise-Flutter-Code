part of 'quiz_three_bloc.dart';

/// Represents the state of QuizThree in the application.

// ignore_for_file: must_be_immutable
class QuizThreeState extends Equatable {
  QuizThreeState({
    this.quizThreeModelObj,
    this.hasSelection = false,
  });

  QuizThreeModel? quizThreeModelObj;
  final bool hasSelection;

  @override
  List<Object?> get props => [quizThreeModelObj, hasSelection];

  QuizThreeState copyWith({
    QuizThreeModel? quizThreeModelObj,
    bool? hasSelection,
  }) {
    return QuizThreeState(
      quizThreeModelObj: quizThreeModelObj ?? this.quizThreeModelObj,
      hasSelection: hasSelection ?? this.hasSelection,
    );
  }
}
