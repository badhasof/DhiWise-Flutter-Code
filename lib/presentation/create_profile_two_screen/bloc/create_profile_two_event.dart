part of 'create_profile_two_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///CreateProfileTwo widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class CreateProfileTwoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the CreateProfileTwo widget is first created.
class CreateProfileTwoInitialEvent extends CreateProfileTwoEvent {
  @override
  List<Object?> get props => [];
}

///Event for changing password visibility

// ignore_for_file: must_be_immutable
class ChangePasswordVisibilityEvent extends CreateProfileTwoEvent {
  ChangePasswordVisibilityEvent({required this.value});

  bool value;

  @override
  List<Object?> get props => [value];
}

/// Event for changing gender selection
class ChangeGenderEvent extends CreateProfileTwoEvent {
  ChangeGenderEvent({required this.value});

  final String value;

  @override
  List<Object?> get props => [value];
}
