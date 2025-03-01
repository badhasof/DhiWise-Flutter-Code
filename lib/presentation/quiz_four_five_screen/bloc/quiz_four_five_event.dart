part of 'quiz_four_five_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizFourFive widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizFourFiveEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizFourFive widget is first created.
class QuizFourFiveInitialEvent extends QuizFourFiveEvent {
  @override
  List<Object?> get props => [];
}
