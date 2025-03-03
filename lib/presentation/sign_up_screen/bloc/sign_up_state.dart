// ignore_for_file: must_be_immutable

part of 'sign_up_bloc.dart';

/// Represents the state of SignUp in the application.
class SignUpState extends Equatable {
  SignUpState({
    this.emailFieldController,
    this.passwordFieldController,
    this.confirmPasswordFieldController,
    this.isShowPassword = true,
    this.isShowConfirmPassword = true,
    this.passwordsMatch = true,
    this.signUpModelObj,
  });

  TextEditingController? emailFieldController;
  TextEditingController? passwordFieldController;
  TextEditingController? confirmPasswordFieldController;

  SignUpModel? signUpModelObj;

  bool isShowPassword;
  bool isShowConfirmPassword;
  bool passwordsMatch;

  @override
  List<Object?> get props => [
        emailFieldController,
        passwordFieldController,
        confirmPasswordFieldController,
        isShowPassword,
        isShowConfirmPassword,
        passwordsMatch,
        signUpModelObj,
      ];

  SignUpState copyWith({
    TextEditingController? emailFieldController,
    TextEditingController? passwordFieldController,
    TextEditingController? confirmPasswordFieldController,
    bool? isShowPassword,
    bool? isShowConfirmPassword,
    bool? passwordsMatch,
    SignUpModel? signUpModelObj,
  }) {
    return SignUpState(
      emailFieldController: emailFieldController ?? this.emailFieldController,
      passwordFieldController:
          passwordFieldController ?? this.passwordFieldController,
      confirmPasswordFieldController:
          confirmPasswordFieldController ?? this.confirmPasswordFieldController,
      isShowPassword: isShowPassword ?? this.isShowPassword,
      isShowConfirmPassword: isShowConfirmPassword ?? this.isShowConfirmPassword,
      passwordsMatch: passwordsMatch ?? this.passwordsMatch,
      signUpModelObj: signUpModelObj ?? this.signUpModelObj,
    );
  }
} 