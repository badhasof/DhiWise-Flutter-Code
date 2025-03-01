part of 'quiz_four_one_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizFourOne widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizFourOneEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizFourOne widget is first created.
class QuizFourOneInitialEvent extends QuizFourOneEvent {
  @override
  List<Object?> get props => [];
}
