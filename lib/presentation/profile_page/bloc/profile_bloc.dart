import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/profile_model.dart';
part 'profile_event.dart';
part 'profile_state.dart';

/// A bloc that manages the state of a Profile according to the event that is dispatched to it.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(ProfileState initialState) : super(initialState) {
    on<ProfileInitialEvent>(_onInitialize);
    on<UpdateUserDataEvent>(_onUpdateUserData);
    on<ToggleEditModeEvent>(_onToggleEditMode);
  }

  _onInitialize(
    ProfileInitialEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          nameFieldController: TextEditingController(),
          usernameFieldController: TextEditingController(),
          passwordFieldController: TextEditingController(),
          emailFieldController: TextEditingController(),
          profileModelObj: ProfileModel(), // Initialize with an empty model
          isEditing: false,
        ),
      );
    } catch (e) {
      print('Error initializing profile: $e');
      // Fallback initialization
      emit(
        state.copyWith(
          nameFieldController: TextEditingController(),
          usernameFieldController: TextEditingController(),
          passwordFieldController: TextEditingController(),
          emailFieldController: TextEditingController(),
          profileModelObj: ProfileModel(), // Initialize with an empty model
          isEditing: false,
        ),
      );
    }
  }

  _onUpdateUserData(
    UpdateUserDataEvent event,
    Emitter<ProfileState> emit,
  ) {
    try {
      final nameController = state.nameFieldController ?? TextEditingController();
      final emailController = state.emailFieldController ?? TextEditingController();
      final usernameController = state.usernameFieldController ?? TextEditingController();

      if (event.displayName != null) {
        nameController.text = event.displayName!;
        // Use displayName as username if username is not set
        usernameController.text = event.displayName!.toLowerCase().replaceAll(' ', '_');
      }

      if (event.email != null) {
        emailController.text = event.email!;
      }

      emit(state.copyWith(
        nameFieldController: nameController,
        emailFieldController: emailController,
        usernameFieldController: usernameController,
        profileModelObj: state.profileModelObj ?? ProfileModel(), // Ensure profileModelObj is not null
      ));
    } catch (e) {
      print('Error updating user data: $e');
    }
  }
  
  _onToggleEditMode(
    ToggleEditModeEvent event,
    Emitter<ProfileState> emit,
  ) {
    try {
      emit(state.copyWith(
        isEditing: !state.isEditing,
      ));
    } catch (e) {
      print('Error toggling edit mode: $e');
    }
  }
}
