part of 'progress_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///Progress widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class ProgressEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the Progress widget is first created.
class ProgressInitialEvent extends ProgressEvent {
  @override
  List<Object?> get props => [];
} 