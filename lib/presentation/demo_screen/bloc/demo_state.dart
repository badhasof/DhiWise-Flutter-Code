part of 'demo_bloc.dart';

/// Represents the state of Demo in the application.

// ignore_for_file: must_be_immutable
class DemoState extends Equatable {
  DemoState({this.demoModelObj});

  DemoModel? demoModelObj;

  @override
  List<Object?> get props => [demoModelObj];
  DemoState copyWith({DemoModel? demoModelObj}) {
    return DemoState(
      demoModelObj: demoModelObj ?? this.demoModelObj,
    );
  }
}
