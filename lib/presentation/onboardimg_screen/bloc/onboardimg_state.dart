part of 'onboardimg_bloc.dart';

/// Represents the state of Onboardimg in the application.

// ignore_for_file: must_be_immutable
class OnboardimgState extends Equatable {
  OnboardimgState({this.onboardimgModelObj});

  OnboardimgModel? onboardimgModelObj;

  @override
  List<Object?> get props => [onboardimgModelObj];
  OnboardimgState copyWith({OnboardimgModel? onboardimgModelObj}) {
    return OnboardimgState(
      onboardimgModelObj: onboardimgModelObj ?? this.onboardimgModelObj,
    );
  }
}
