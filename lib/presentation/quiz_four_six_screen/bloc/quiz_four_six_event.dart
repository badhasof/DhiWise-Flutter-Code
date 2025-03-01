part of 'quiz_four_six_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizFourSix widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizFourSixEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizFourSix widget is first created.
class QuizFourSixInitialEvent extends QuizFourSixEvent {
  @override
  List<Object?> get props => [];
}
