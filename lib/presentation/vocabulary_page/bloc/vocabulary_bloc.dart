import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../../core/app_export.dart';
import '../../../services/demo_timer_service.dart';
import '../models/vocabulary_model.dart';
part 'vocabulary_event.dart';
part 'vocabulary_state.dart';

/// A bloc that manages the state of a Vocabulary according to the event that is dispatched to it.
class VocabularyBloc extends Bloc<VocabularyEvent, VocabularyState> {
  // Timer for updating UI
  Timer? _timer;
  
  VocabularyBloc(VocabularyState initialState) : super(initialState) {
    on<VocabularyInitialEvent>(_onInitialize);
  }

  _onInitialize(
    VocabularyInitialEvent event,
    Emitter<VocabularyState> emit,
  ) async {
    // Initialize with current time from the demo timer service
    final int initialRemainingTime = DemoTimerService.instance.refreshRemainingTime();
    
    emit(state.copyWith(
      vocabularyModelObj: VocabularyModel(
        remainingTime: initialRemainingTime,
      ),
    ));
    
    // Set up a timer to update the UI every second
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      final int remainingTime = DemoTimerService.instance.refreshRemainingTime();
      
      // Update the state with the new time
      emit(state.copyWith(
        vocabularyModelObj: state.vocabularyModelObj?.copyWith(
          remainingTime: remainingTime,
        ),
      ));
    });
  }
  
  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
