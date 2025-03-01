part of 'quiz_one_bloc.dart';

/// Represents the state of QuizOne in the application.

// ignore_for_file: must_be_immutable
class QuizOneState extends Equatable {
  final QuizOneModel? quizOneModelObj;
  final bool hasSelection;

  const QuizOneState({
    this.quizOneModelObj,
    this.hasSelection = false,
  });

  QuizOneState copyWith({
    QuizOneModel? quizOneModelObj,
    bool? hasSelection,
  }) {
    return QuizOneState(
      quizOneModelObj: quizOneModelObj ?? this.quizOneModelObj,
      hasSelection: hasSelection ?? this.hasSelection,
    );
  }

  @override
  List<Object?> get props => [quizOneModelObj, hasSelection];
}
