part of 'quiz_four_eight_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizFourEight widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizFourEightEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizFourEight widget is first created.
class QuizFourEightInitialEvent extends QuizFourEightEvent {
  @override
  List<Object?> get props => [];
}
