part of 'vocabulary_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///Vocabulary widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class VocabularyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the Vocabulary widget is first created.
class VocabularyInitialEvent extends VocabularyEvent {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the timer needs to be updated.
class VocabularyUpdateTimerEvent extends VocabularyEvent {
  final int remainingTime;

  VocabularyUpdateTimerEvent({required this.remainingTime});
  
  @override
  List<Object?> get props => [remainingTime];
}
