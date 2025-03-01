part of 'sign_in_bloc.dart';

/// Represents the state of SignIn in the application.

// ignore_for_file: must_be_immutable
class SignInState extends Equatable {
  SignInState({
    this.usernameFieldController,
    this.passwordFieldController,
    this.isShowPassword = true,
    this.signInModelObj});

  TextEditingController? usernameFieldController;
  TextEditingController? passwordFieldController;
  SignInModel? signInModelObj;

  bool isShowPassword;

  @override
  List<Object?> get props => [
        usernameFieldController,
        passwordFieldController,
        isShowPassword,
        signInModelObj
      ];

  SignInState copyWith({
    TextEditingController? usernameFieldController,
    TextEditingController? passwordFieldController,
    bool? isShowPassword,
    SignInModel? signInModelObj,
  }) {
    return SignInState(
      usernameFieldController: usernameFieldController ?? this.usernameFieldController,
      passwordFieldController: passwordFieldController ?? this.passwordFieldController,
      isShowPassword: isShowPassword ?? this.isShowPassword,
      signInModelObj: signInModelObj ?? this.signInModelObj,
    );
  }
}
