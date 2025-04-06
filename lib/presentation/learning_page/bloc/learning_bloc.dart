import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/learning_model.dart';
part 'learning_event.dart';
part 'learning_state.dart';

/// A bloc that manages the state of a Learning according to the event that is dispatched to it.
class LearningBloc extends Bloc<LearningEvent, LearningState> {
  LearningBloc(LearningState initialState) : super(initialState) {
    on<LearningInitialEvent>(_onInitialize);
  }

  _onInitialize(
    LearningInitialEvent event,
    Emitter<LearningState> emit,
  ) async {
    try {
      // Initialize with an empty model if not already initialized
      if (state.learningModelObj == null) {
        emit(state.copyWith(
          learningModelObj: LearningModel(),
        ));
      }
    } catch (e) {
      print('Error in LearningBloc initialization: $e');
      // Fallback initialization
      emit(state.copyWith(
        learningModelObj: LearningModel(),
      ));
    }
  }
} 