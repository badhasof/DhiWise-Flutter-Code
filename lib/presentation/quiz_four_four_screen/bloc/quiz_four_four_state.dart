part of 'quiz_four_four_bloc.dart';

/// Represents the state of QuizFourFour in the application.

// ignore_for_file: must_be_immutable
class QuizFourFourState extends Equatable {
  QuizFourFourState({this.quizFourFourModelObj});

  QuizFourFourModel? quizFourFourModelObj;

  @override
  List<Object?> get props => [quizFourFourModelObj];
  QuizFourFourState copyWith({QuizFourFourModel? quizFourFourModelObj}) {
    return QuizFourFourState(
      quizFourFourModelObj: quizFourFourModelObj ?? this.quizFourFourModelObj,
    );
  }
}
