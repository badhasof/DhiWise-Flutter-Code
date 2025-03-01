part of 'quiz_four_two_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizFourTwo widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizFourTwoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizFourTwo widget is first created.
class QuizFourTwoInitialEvent extends QuizFourTwoEvent {
  @override
  List<Object?> get props => [];
}
