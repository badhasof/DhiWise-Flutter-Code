part of 'quiz_one_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizOne widget.
///
/// Events must be immutable and implement the [Equatable] interface.
abstract class QuizOneEvent extends Equatable {}

/// Event that is dispatched when the QuizOne widget is first created.
class QuizOneInitialEvent extends QuizOneEvent {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when an option is selected
class SelectOptionEvent extends QuizOneEvent {
  final OptionslistItemModel option;

  SelectOptionEvent(this.option);

  @override
  List<Object?> get props => [option];
}
