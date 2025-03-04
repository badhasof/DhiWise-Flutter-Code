part of 'create_profile_two_bloc.dart';

/// Represents the state of CreateProfileTwo in the application.

// ignore_for_file: must_be_immutable
class CreateProfileTwoState extends Equatable {
  CreateProfileTwoState({
    this.ageFieldController,
    this.nameFieldController,
    this.genderValue,
    this.createProfileTwoModelObj,
  });

  TextEditingController? ageFieldController;
  TextEditingController? nameFieldController;
  String? genderValue;
  CreateProfileTwoModel? createProfileTwoModelObj;

  @override
  List<Object?> get props => [
        ageFieldController,
        nameFieldController,
        genderValue,
        createProfileTwoModelObj,
      ];

  CreateProfileTwoState copyWith({
    TextEditingController? ageFieldController,
    TextEditingController? nameFieldController,
    String? genderValue,
    CreateProfileTwoModel? createProfileTwoModelObj,
  }) {
    return CreateProfileTwoState(
      ageFieldController: ageFieldController ?? this.ageFieldController,
      nameFieldController: nameFieldController ?? this.nameFieldController,
      genderValue: genderValue ?? this.genderValue,
      createProfileTwoModelObj:
          createProfileTwoModelObj ?? this.createProfileTwoModelObj,
    );
  }
}
