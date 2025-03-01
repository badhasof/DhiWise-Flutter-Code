part of 'quiz_four_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizFour widget.
///
/// Events must be immutable and implement the [Equatable] interface.
abstract class QuizFourEvent extends Equatable {}

/// Event that is dispatched when the QuizFour widget is first created.
class QuizFourInitialEvent extends QuizFourEvent {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when an option is selected
class SelectOptionEvent extends QuizFourEvent {
  final OptionsgridItemModel option;

  SelectOptionEvent(this.option);

  @override
  List<Object?> get props => [option];
}
