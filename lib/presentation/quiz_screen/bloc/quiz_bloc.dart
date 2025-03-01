import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/quiz_model.dart';
part 'quiz_event.dart';
part 'quiz_state.dart';

/// A bloc that manages the state of a Quiz according to the event that is dispatched to it.
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc(QuizState initialState) : super(initialState) {
    on<QuizInitialEvent>(_onInitialize);
  }

  _onInitialize(
    QuizInitialEvent event,
    Emitter<QuizState> emit,
  ) async {}
}
