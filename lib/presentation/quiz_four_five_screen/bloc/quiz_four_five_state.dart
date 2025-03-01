part of 'quiz_four_five_bloc.dart';

/// Represents the state of QuizFourFive in the application.

// ignore_for_file: must_be_immutable
class QuizFourFiveState extends Equatable {
  QuizFourFiveState({this.quizFourFiveModelObj});

  QuizFourFiveModel? quizFourFiveModelObj;

  @override
  List<Object?> get props => [quizFourFiveModelObj];
  QuizFourFiveState copyWith({QuizFourFiveModel? quizFourFiveModelObj}) {
    return QuizFourFiveState(
      quizFourFiveModelObj: quizFourFiveModelObj ?? this.quizFourFiveModelObj,
    );
  }
}
