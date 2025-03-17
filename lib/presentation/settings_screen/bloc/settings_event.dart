part of 'settings_bloc.dart';

/// Abstract class for all events that can be dispatched from the
/// Settings widget.
///
/// Events must be immutable and implement the [Equatable] interface.
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the Settings screen is first opened
class SettingsInitialEvent extends SettingsEvent {
  @override
  List<Object?> get props => [];
} 