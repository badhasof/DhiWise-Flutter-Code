part of 'quiz_bloc.dart';

/// Represents the state of Quiz in the application.

// ignore_for_file: must_be_immutable
class QuizState extends Equatable {
  QuizState({this.quizModelObj});

  QuizModel? quizModelObj;

  @override
  List<Object?> get props => [quizModelObj];
  QuizState copyWith({QuizModel? quizModelObj}) {
    return QuizState(
      quizModelObj: quizModelObj ?? this.quizModelObj,
    );
  }
}

