part of 'create_profile_one_bloc.dart';

/// Represents the state of CreateProfileOne in the application.

// ignore_for_file: must_be_immutable
class CreateProfileOneState extends Equatable {
  CreateProfileOneState({this.createProfileOneModelObj});

  CreateProfileOneModel? createProfileOneModelObj;

  @override
  List<Object?> get props => [createProfileOneModelObj];
  CreateProfileOneState copyWith(
      {CreateProfileOneModel? createProfileOneModelObj}) {
    return CreateProfileOneState(
      createProfileOneModelObj:
          createProfileOneModelObj ?? this.createProfileOneModelObj,
    );
  }
}
