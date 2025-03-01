part of 'quiz_four_eight_bloc.dart';

/// Represents the state of QuizFourEight in the application.

// ignore_for_file: must_be_immutable
class QuizFourEightState extends Equatable {
  QuizFourEightState({this.quizFourEightModelObj});

  QuizFourEightModel? quizFourEightModelObj;

  @override
  List<Object?> get props => [quizFourEightModelObj];
  QuizFourEightState copyWith({QuizFourEightModel? quizFourEightModelObj}) {
    return QuizFourEightState(
      quizFourEightModelObj:
          quizFourEightModelObj ?? this.quizFourEightModelObj,
    );
  }
}
