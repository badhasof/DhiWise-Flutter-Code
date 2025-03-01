part of 'quiz_two_bloc.dart';

/// Represents the state of QuizTwo in the application.

// ignore_for_file: must_be_immutable
class QuizTwoState extends Equatable {
  QuizTwoState({
    this.quizTwoModelObj,
    this.hasSelection = false,
  });

  QuizTwoModel? quizTwoModelObj;
  final bool hasSelection;

  @override
  List<Object?> get props => [quizTwoModelObj, hasSelection];

  QuizTwoState copyWith({
    QuizTwoModel? quizTwoModelObj,
    bool? hasSelection,
  }) {
    return QuizTwoState(
      quizTwoModelObj: quizTwoModelObj ?? this.quizTwoModelObj,
      hasSelection: hasSelection ?? this.hasSelection,
    );
  }
}
