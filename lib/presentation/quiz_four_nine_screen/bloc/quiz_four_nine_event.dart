part of 'quiz_four_nine_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizFourNine widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizFourNineEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizFourNine widget is first created.
class QuizFourNineInitialEvent extends QuizFourNineEvent {
  @override
  List<Object?> get props => [];
}
