import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/onboardimg_model.dart';
part 'onboardimg_event.dart';
part 'onboardimg_state.dart';

/// A bloc that manages the state of a Onboardimg according to the event that is dispatched to it.
class OnboardimgBloc extends Bloc<OnboardimgEvent, OnboardimgState> {
  OnboardimgBloc(OnboardimgState initialState) : super(initialState) {
    on<OnboardimgInitialEvent>(_onInitialize);
  }

  _onInitialize(
    OnboardimgInitialEvent event,
    Emitter<OnboardimgState> emit,
  ) async {}
}
