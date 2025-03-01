part of 'quiz_three_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizThree widget.
///
/// Events must be immutable and implement the [Equatable] interface.
abstract class QuizThreeEvent extends Equatable {}

/// Event that is dispatched when the QuizThree widget is first created.
class QuizThreeInitialEvent extends QuizThreeEvent {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when an option is selected
class SelectOptionEvent extends QuizThreeEvent {
  final OptionslistItemModel option;

  SelectOptionEvent(this.option);

  @override
  List<Object?> get props => [option];
}
