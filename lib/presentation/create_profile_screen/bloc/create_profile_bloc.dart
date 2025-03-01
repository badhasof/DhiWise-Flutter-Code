import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/create_profile_model.dart';
part 'create_profile_event.dart';
part 'create_profile_state.dart';

/// A bloc that manages the state of a CreateProfile according to the event that is dispatched to it.
class CreateProfileBloc extends Bloc<CreateProfileEvent, CreateProfileState> {
  CreateProfileBloc(CreateProfileState initialState) : super(initialState) {
    on<CreateProfileInitialEvent>(_onInitialize);
  }

  _onInitialize(
    CreateProfileInitialEvent event,
    Emitter<CreateProfileState> emit,
  ) async {}
}
