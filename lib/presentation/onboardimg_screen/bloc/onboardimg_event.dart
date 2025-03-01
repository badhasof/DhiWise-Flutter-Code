part of 'onboardimg_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///Onboardimg widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class OnboardimgEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the Onboardimg widget is first created.
class OnboardimgInitialEvent extends OnboardimgEvent {
  @override
  List<Object?> get props => [];
}
