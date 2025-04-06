import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/progress_model.dart';
part 'progress_event.dart';
part 'progress_state.dart';

/// A bloc that manages the state of a Progress according to the event that is dispatched to it.
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  ProgressBloc(ProgressState initialState) : super(initialState) {
    on<ProgressInitialEvent>(_onInitialize);
  }

  _onInitialize(
    ProgressInitialEvent event,
    Emitter<ProgressState> emit,
  ) async {
    try {
      // Initialize with an empty model if not already initialized
      if (state.progressModelObj == null) {
        emit(state.copyWith(
          progressModelObj: ProgressModel(),
        ));
      }
    } catch (e) {
      print('Error in ProgressBloc initialization: $e');
      // Fallback initialization
      emit(state.copyWith(
        progressModelObj: ProgressModel(),
      ));
    }
  }
} 