part of 'quiz_four_two_bloc.dart';

/// Represents the state of QuizFourTwo in the application.

// ignore_for_file: must_be_immutable
class QuizFourTwoState extends Equatable {
  QuizFourTwoState({this.quizFourTwoModelObj});

  QuizFourTwoModel? quizFourTwoModelObj;

  @override
  List<Object?> get props => [quizFourTwoModelObj];
  QuizFourTwoState copyWith({QuizFourTwoModel? quizFourTwoModelObj}) {
    return QuizFourTwoState(
      quizFourTwoModelObj: quizFourTwoModelObj ?? this.quizFourTwoModelObj,
    );
  }
}
