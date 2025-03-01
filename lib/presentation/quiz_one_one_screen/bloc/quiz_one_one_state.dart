part of 'quiz_one_one_bloc.dart';

/// Represents the state of QuizOneOne in the application.

// ignore_for_file: must_be_immutable
class QuizOneOneState extends Equatable {
  QuizOneOneState({this.quizOneOneModelObj});

  QuizOneOneModel? quizOneOneModelObj;

  @override
  List<Object?> get props => [quizOneOneModelObj];
  QuizOneOneState copyWith({QuizOneOneModel? quizOneOneModelObj}) {
    return QuizOneOneState(
      quizOneOneModelObj: quizOneOneModelObj ?? this.quizOneOneModelObj,
    );
  }
}
