part of 'learning_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///Learning widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class LearningEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the Learning widget is first created.
class LearningInitialEvent extends LearningEvent {
  @override
  List<Object?> get props => [];
} 