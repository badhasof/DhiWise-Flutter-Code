part of 'profile_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///Profile widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the Profile widget is first created.
class ProfileInitialEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

/// Event to update user data in the profile
class UpdateUserDataEvent extends ProfileEvent {
  final String? email;
  final String? displayName;

  UpdateUserDataEvent({
    this.email,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, displayName];
}

/// Event to toggle edit mode on or off
class ToggleEditModeEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}
