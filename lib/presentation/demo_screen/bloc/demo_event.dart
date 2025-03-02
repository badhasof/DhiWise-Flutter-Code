part of 'demo_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///Demo widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class DemoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the Demo widget is first created.
class DemoInitialEvent extends DemoEvent {
  @override
  List<Object?> get props => [];
}
