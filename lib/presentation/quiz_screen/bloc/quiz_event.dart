part of 'quiz_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///Quiz widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the Quiz widget is first created.
class QuizInitialEvent extends QuizEvent {
  @override
  List<Object?> get props => [];
}
