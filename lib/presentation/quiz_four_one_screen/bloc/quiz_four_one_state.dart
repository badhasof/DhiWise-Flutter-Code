part of 'quiz_four_one_bloc.dart';

/// Represents the state of QuizFourOne in the application.

// ignore_for_file: must_be_immutable
class QuizFourOneState extends Equatable {
  QuizFourOneState({this.quizFourOneModelObj});

  QuizFourOneModel? quizFourOneModelObj;

  @override
  List<Object?> get props => [quizFourOneModelObj];
  QuizFourOneState copyWith({QuizFourOneModel? quizFourOneModelObj}) {
    return QuizFourOneState(
      quizFourOneModelObj: quizFourOneModelObj ?? this.quizFourOneModelObj,
    );
  }
}
