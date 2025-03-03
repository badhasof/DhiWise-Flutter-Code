// ignore_for_file: must_be_immutable

part of 'sign_up_bloc.dart';

/// Abstract class for all events that can be dispatched from the
/// SignUp widget.
///
/// Events must be immutable and implement the [Equatable] interface.
@immutable
abstract class SignUpEvent extends Equatable {}

/// Event that is dispatched when the SignUp widget is first created.
class SignUpInitialEvent extends SignUpEvent {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the user toggles the password visibility
class ChangePasswordVisibilityEvent extends SignUpEvent {
  ChangePasswordVisibilityEvent({required this.value});

  final bool value;

  @override
  List<Object?> get props => [value];
}

/// Event that is dispatched when the user toggles the confirm password visibility
class ChangeConfirmPasswordVisibilityEvent extends SignUpEvent {
  ChangeConfirmPasswordVisibilityEvent({required this.value});

  final bool value;

  @override
  List<Object?> get props => [value];
}

/// Event that is dispatched when the user types in the confirm password field
class ValidatePasswordMatchEvent extends SignUpEvent {
  @override
  List<Object?> get props => [];
} 