import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/demo_model.dart';
part 'demo_event.dart';
part 'demo_state.dart';

/// A bloc that manages the state of a Demo according to the event that is dispatched to it.
class DemoBloc extends Bloc<DemoEvent, DemoState> {
  DemoBloc(DemoState initialState) : super(initialState) {
    on<DemoInitialEvent>(_onInitialize);
  }

  _onInitialize(
    DemoInitialEvent event,
    Emitter<DemoState> emit,
  ) async {}
}
