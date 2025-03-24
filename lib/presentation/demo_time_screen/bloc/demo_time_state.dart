import 'package:equatable/equatable.dart';
import '../models/demo_time_model.dart';

class DemoTimeState extends Equatable {
  final DemoTimeModel demoTimeModelObj;

  const DemoTimeState({required this.demoTimeModelObj});

  @override
  List<Object?> get props => [demoTimeModelObj];

  DemoTimeState copyWith({DemoTimeModel? demoTimeModelObj}) {
    return DemoTimeState(
      demoTimeModelObj: demoTimeModelObj ?? this.demoTimeModelObj,
    );
  }
} 