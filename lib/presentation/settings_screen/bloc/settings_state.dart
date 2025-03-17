part of 'settings_bloc.dart';

/// Represents the state of Settings in the application.
class SettingsState extends Equatable {
  final SettingsModel? settingsModelObj;

  const SettingsState({
    this.settingsModelObj,
  });

  SettingsState copyWith({
    SettingsModel? settingsModelObj,
  }) {
    return SettingsState(
      settingsModelObj: settingsModelObj ?? this.settingsModelObj,
    );
  }

  @override
  List<Object?> get props => [
        settingsModelObj,
      ];
} 