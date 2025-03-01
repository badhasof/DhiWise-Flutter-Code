part of 'quiz_four_three_bloc.dart';

/// Represents the state of QuizFourThree in the application.

// ignore_for_file: must_be_immutable
class QuizFourThreeState extends Equatable {
  QuizFourThreeState({this.quizFourThreeModelObj});

  QuizFourThreeModel? quizFourThreeModelObj;

  @override
  List<Object?> get props => [quizFourThreeModelObj];
  QuizFourThreeState copyWith({QuizFourThreeModel? quizFourThreeModelObj}) {
    return QuizFourThreeState(
      quizFourThreeModelObj:
          quizFourThreeModelObj ?? this.quizFourThreeModelObj,
    );
  }
}
