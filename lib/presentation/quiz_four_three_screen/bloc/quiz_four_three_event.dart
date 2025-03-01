part of 'quiz_four_three_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizFourThree widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizFourThreeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizFourThree widget is first created.
class QuizFourThreeInitialEvent extends QuizFourThreeEvent {
  @override
  List<Object?> get props => [];
}
