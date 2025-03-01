part of 'create_profile_bloc.dart';

/// Represents the state of CreateProfile in the application.

// ignore_for_file: must_be_immutable
class CreateProfileState extends Equatable {
  CreateProfileState({this.createProfileModelObj});

  CreateProfileModel? createProfileModelObj;

  @override
  List<Object?> get props => [createProfileModelObj];
  CreateProfileState copyWith({CreateProfileModel? createProfileModelObj}) {
    return CreateProfileState(
      createProfileModelObj:
          createProfileModelObj ?? this.createProfileModelObj,
    );
  }
}
