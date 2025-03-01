part of 'quiz_four_seven_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizFourSeven widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizFourSevenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizFourSeven widget is first created.
class QuizFourSevenInitialEvent extends QuizFourSevenEvent {
  @override
  List<Object?> get props => [];
}
