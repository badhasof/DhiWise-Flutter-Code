import 'package:equatable/equatable.dart';

abstract class DemoTimeEvent extends Equatable {}

/// Event that is triggered when the screen is initialized
class DemoTimeInitialEvent extends DemoTimeEvent {
  @override
  List<Object?> get props => [];
}

/// Event that is triggered when the slider value changes
class UpdateMinutesEvent extends DemoTimeEvent {
  final int minutes;

  UpdateMinutesEvent({required this.minutes});

  @override
  List<Object?> get props => [minutes];
} 