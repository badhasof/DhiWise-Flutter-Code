part of 'quiz_one_one_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizOneOne widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizOneOneEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizOneOne widget is first created.
class QuizOneOneInitialEvent extends QuizOneOneEvent {
  @override
  List<Object?> get props => [];
}
