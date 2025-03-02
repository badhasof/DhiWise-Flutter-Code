part of 'profile_bloc.dart';

/// Represents the state of Profile in the application.

// ignore_for_file: must_be_immutable
class ProfileState extends Equatable {
  ProfileState(
      {this.nameFieldController,
      this.usernameFieldController,
      this.passwordFieldController,
      this.emailFieldController,
      this.profileModelObj});

  TextEditingController? nameFieldController;

  TextEditingController? usernameFieldController;

  TextEditingController? passwordFieldController;

  TextEditingController? emailFieldController;

  ProfileModel? profileModelObj;

  @override
  List<Object?> get props => [
        nameFieldController,
        usernameFieldController,
        passwordFieldController,
        emailFieldController,
        profileModelObj
      ];
  ProfileState copyWith({
    TextEditingController? nameFieldController,
    TextEditingController? usernameFieldController,
    TextEditingController? passwordFieldController,
    TextEditingController? emailFieldController,
    ProfileModel? profileModelObj,
  }) {
    return ProfileState(
      nameFieldController: nameFieldController ?? this.nameFieldController,
      usernameFieldController:
          usernameFieldController ?? this.usernameFieldController,
      passwordFieldController:
          passwordFieldController ?? this.passwordFieldController,
      emailFieldController: emailFieldController ?? this.emailFieldController,
      profileModelObj: profileModelObj ?? this.profileModelObj,
    );
  }
}
