import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/settings_model.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// A bloc that manages the state of a Settings according to the event that is dispatched to it.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(SettingsState initialState) : super(initialState) {
    on<SettingsInitialEvent>(_onInitialize);
  }

  _onInitialize(
    SettingsInitialEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      settingsModelObj: SettingsModel(),
    ));
  }
} 