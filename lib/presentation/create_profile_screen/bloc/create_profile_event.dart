part of 'create_profile_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///CreateProfile widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class CreateProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the CreateProfile widget is first created.
class CreateProfileInitialEvent extends CreateProfileEvent {
  @override
  List<Object?> get props => [];
}
