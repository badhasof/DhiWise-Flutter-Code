part of 'quiz_three_one_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizThreeOne widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizThreeOneEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizThreeOne widget is first created.
class QuizThreeOneInitialEvent extends QuizThreeOneEvent {
  @override
  List<Object?> get props => [];
}
