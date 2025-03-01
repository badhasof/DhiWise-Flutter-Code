part of 'quiz_three_one_bloc.dart';

/// Represents the state of QuizThreeOne in the application.

// ignore_for_file: must_be_immutable
class QuizThreeOneState extends Equatable {
  QuizThreeOneState({this.quizThreeOneModelObj});

  QuizThreeOneModel? quizThreeOneModelObj;

  @override
  List<Object?> get props => [quizThreeOneModelObj];
  QuizThreeOneState copyWith({QuizThreeOneModel? quizThreeOneModelObj}) {
    return QuizThreeOneState(
      quizThreeOneModelObj: quizThreeOneModelObj ?? this.quizThreeOneModelObj,
    );
  }
}
