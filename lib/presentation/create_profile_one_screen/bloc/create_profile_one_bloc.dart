import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/create_profile_one_model.dart';
part 'create_profile_one_event.dart';
part 'create_profile_one_state.dart';

/// A bloc that manages the state of a CreateProfileOne according to the event that is dispatched to it.
class CreateProfileOneBloc
    extends Bloc<CreateProfileOneEvent, CreateProfileOneState> {
  CreateProfileOneBloc(CreateProfileOneState initialState)
      : super(initialState) {
    on<CreateProfileOneInitialEvent>(_onInitialize);
  }

  _onInitialize(
    CreateProfileOneInitialEvent event,
    Emitter<CreateProfileOneState> emit,
  ) async {}
}
