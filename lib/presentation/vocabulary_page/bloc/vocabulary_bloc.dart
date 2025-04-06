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
    on<VocabularyUpdateTimerEvent>(_onUpdateTimer);
  }

  _onInitialize(
    VocabularyInitialEvent event,
    Emitter<VocabularyState> emit,
  ) async {
    try {
      // Initialize with current time from the demo timer service
      final int initialRemainingTime = DemoTimerService.instance.refreshRemainingTime();
      
      emit(state.copyWith(
        vocabularyModelObj: VocabularyModel(
          remainingTime: initialRemainingTime,
        ),
      ));
      
      // Start the timer outside of the bloc event handler
      _startTimer();
    } catch (e) {
      print('Error in VocabularyBloc initialization: $e');
      // Initialize with a default value to prevent late initialization errors
      emit(state.copyWith(
        vocabularyModelObj: VocabularyModel(
          remainingTime: 0,
        ),
      ));
    }
  }
  
  _onUpdateTimer(
    VocabularyUpdateTimerEvent event,
    Emitter<VocabularyState> emit,
  ) {
    try {
      // Update the state with the new time
      emit(state.copyWith(
        vocabularyModelObj: state.vocabularyModelObj?.copyWith(
          remainingTime: event.remainingTime,
        ),
      ));
    } catch (e) {
      print('Error in timer update: $e');
    }
  }
  
  void _startTimer() {
    try {
      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 1), (_) {
        try {
          final int remainingTime = DemoTimerService.instance.refreshRemainingTime();
          add(VocabularyUpdateTimerEvent(remainingTime: remainingTime));
        } catch (e) {
          print('Error refreshing timer: $e');
          // Don't propagate the error, just log it
        }
      });
    } catch (e) {
      print('Error starting timer: $e');
    }
  }
  
  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
