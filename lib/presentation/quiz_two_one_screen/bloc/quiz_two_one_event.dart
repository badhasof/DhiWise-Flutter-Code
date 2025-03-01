part of 'quiz_two_one_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizTwoOne widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizTwoOneEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizTwoOne widget is first created.
class QuizTwoOneInitialEvent extends QuizTwoOneEvent {
  @override
  List<Object?> get props => [];
}
