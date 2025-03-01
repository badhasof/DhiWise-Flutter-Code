part of 'quiz_four_four_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizFourFour widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizFourFourEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizFourFour widget is first created.
class QuizFourFourInitialEvent extends QuizFourFourEvent {
  @override
  List<Object?> get props => [];
}
