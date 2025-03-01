part of 'quiz_four_six_bloc.dart';

/// Represents the state of QuizFourSix in the application.

// ignore_for_file: must_be_immutable
class QuizFourSixState extends Equatable {
  QuizFourSixState({this.quizFourSixModelObj});

  QuizFourSixModel? quizFourSixModelObj;

  @override
  List<Object?> get props => [quizFourSixModelObj];
  QuizFourSixState copyWith({QuizFourSixModel? quizFourSixModelObj}) {
    return QuizFourSixState(
      quizFourSixModelObj: quizFourSixModelObj ?? this.quizFourSixModelObj,
    );
  }
}
