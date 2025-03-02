import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/create_profile_two_model.dart';
part 'create_profile_two_event.dart';
part 'create_profile_two_state.dart';

/// A bloc that manages the state of a CreateProfileTwo according to the event that is dispatched to it.
class CreateProfileTwoBloc
    extends Bloc<CreateProfileTwoEvent, CreateProfileTwoState> {
  CreateProfileTwoBloc(CreateProfileTwoState initialState)
      : super(initialState) {
    on<CreateProfileTwoInitialEvent>(_onInitialize);
    on<ChangePasswordVisibilityEvent>(_changePasswordVisibility);
  }

  _onInitialize(
    CreateProfileTwoInitialEvent event,
    Emitter<CreateProfileTwoState> emit,
  ) async {
    emit(
      state.copyWith(
        ageFieldController: TextEditingController(),
        nameFieldController: TextEditingController(),
        emailFieldController: TextEditingController(),
        passwordFieldController: TextEditingController(),
        isShowPassword: true,
      ),
    );
  }

  _changePasswordVisibility(
    ChangePasswordVisibilityEvent event,
    Emitter<CreateProfileTwoState> emit,
  ) {
    emit(state.copyWith(
      isShowPassword: event.value,
    ));
  }
}
