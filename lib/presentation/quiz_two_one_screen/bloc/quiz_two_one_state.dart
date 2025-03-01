part of 'quiz_two_one_bloc.dart';

/// Represents the state of QuizTwoOne in the application.

// ignore_for_file: must_be_immutable
class QuizTwoOneState extends Equatable {
  QuizTwoOneState({this.quizTwoOneModelObj});

  QuizTwoOneModel? quizTwoOneModelObj;

  @override
  List<Object?> get props => [quizTwoOneModelObj];
  QuizTwoOneState copyWith({QuizTwoOneModel? quizTwoOneModelObj}) {
    return QuizTwoOneState(
      quizTwoOneModelObj: quizTwoOneModelObj ?? this.quizTwoOneModelObj,
    );
  }
}
