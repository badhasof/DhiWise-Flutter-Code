part of 'create_profile_two_bloc.dart';

/// Represents the state of CreateProfileTwo in the application.

// ignore_for_file: must_be_immutable
class CreateProfileTwoState extends Equatable {
  CreateProfileTwoState(
      {this.ageFieldController,
      this.nameFieldController,
      this.emailFieldController,
      this.passwordFieldController,
      this.isShowPassword = true,
      this.createProfileTwoModelObj});

  TextEditingController? ageFieldController;

  TextEditingController? nameFieldController;

  TextEditingController? emailFieldController;

  TextEditingController? passwordFieldController;

  CreateProfileTwoModel? createProfileTwoModelObj;

  bool isShowPassword;

  @override
  List<Object?> get props => [
        ageFieldController,
        nameFieldController,
        emailFieldController,
        passwordFieldController,
        isShowPassword,
        createProfileTwoModelObj
      ];
  CreateProfileTwoState copyWith({
    TextEditingController? ageFieldController,
    TextEditingController? nameFieldController,
    TextEditingController? emailFieldController,
    TextEditingController? passwordFieldController,
    bool? isShowPassword,
    CreateProfileTwoModel? createProfileTwoModelObj,
  }) {
    return CreateProfileTwoState(
      ageFieldController: ageFieldController ?? this.ageFieldController,
      nameFieldController: nameFieldController ?? this.nameFieldController,
      emailFieldController: emailFieldController ?? this.emailFieldController,
      passwordFieldController:
          passwordFieldController ?? this.passwordFieldController,
      isShowPassword: isShowPassword ?? this.isShowPassword,
      createProfileTwoModelObj:
          createProfileTwoModelObj ?? this.createProfileTwoModelObj,
    );
  }
}
