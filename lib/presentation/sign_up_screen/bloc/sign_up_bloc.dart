import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_export.dart';
import '../models/sign_up_model.dart';
part 'sign_up_event.dart';
part 'sign_up_state.dart';

/// A bloc that manages the state of a SignUp according to the event that is dispatched to it.
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc(SignUpState initialState) : super(initialState) {
    on<SignUpInitialEvent>(_onInitialize);
    on<ChangePasswordVisibilityEvent>(_changePasswordVisibility);
    on<ChangeConfirmPasswordVisibilityEvent>(_changeConfirmPasswordVisibility);
    on<ValidatePasswordMatchEvent>(_validatePasswordMatch);
  }

  _onInitialize(
    SignUpInitialEvent event,
    Emitter<SignUpState> emit,
  ) async {
    emit(
      state.copyWith(
        emailFieldController: TextEditingController(),
        passwordFieldController: TextEditingController(),
        confirmPasswordFieldController: TextEditingController(),
        isShowPassword: true,
        isShowConfirmPassword: true,
        passwordsMatch: true,
      ),
    );
  }

  _changePasswordVisibility(
    ChangePasswordVisibilityEvent event,
    Emitter<SignUpState> emit,
  ) {
    emit(state.copyWith(
      isShowPassword: event.value,
    ));
  }

  _changeConfirmPasswordVisibility(
    ChangeConfirmPasswordVisibilityEvent event,
    Emitter<SignUpState> emit,
  ) {
    emit(state.copyWith(
      isShowConfirmPassword: event.value,
    ));
  }

  _validatePasswordMatch(
    ValidatePasswordMatchEvent event,
    Emitter<SignUpState> emit,
  ) {
    final password = state.passwordFieldController?.text ?? '';
    final confirmPassword = state.confirmPasswordFieldController?.text ?? '';
    final passwordsMatch = password == confirmPassword;
    
    emit(state.copyWith(
      passwordsMatch: passwordsMatch,
    ));
  }
} 