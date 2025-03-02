part of 'create_profile_one_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///CreateProfileOne widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class CreateProfileOneEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the CreateProfileOne widget is first created.
class CreateProfileOneInitialEvent extends CreateProfileOneEvent {
  @override
  List<Object?> get props => [];
}
