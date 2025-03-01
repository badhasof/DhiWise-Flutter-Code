part of 'quiz_four_ten_bloc.dart';

/// Represents the state of QuizFourTen in the application.

// ignore_for_file: must_be_immutable
class QuizFourTenState extends Equatable {
  QuizFourTenState({this.quizFourTenModelObj});

  QuizFourTenModel? quizFourTenModelObj;

  @override
  List<Object?> get props => [quizFourTenModelObj];
  QuizFourTenState copyWith({QuizFourTenModel? quizFourTenModelObj}) {
    return QuizFourTenState(
      quizFourTenModelObj: quizFourTenModelObj ?? this.quizFourTenModelObj,
    );
  }
}
