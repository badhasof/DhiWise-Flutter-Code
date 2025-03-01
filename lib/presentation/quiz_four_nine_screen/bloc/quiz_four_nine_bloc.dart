import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/quiz_four_nine_model.dart';
part 'quiz_four_nine_event.dart';
part 'quiz_four_nine_state.dart';

/// A bloc that manages the state of a QuizFourNine according to the event that is dispatched to it.
class QuizFourNineBloc extends Bloc<QuizFourNineEvent, QuizFourNineState> {
  QuizFourNineBloc(QuizFourNineState initialState) : super(initialState) {
    on<QuizFourNineInitialEvent>(_onInitialize);
  }

  _onInitialize(
    QuizFourNineInitialEvent event,
    Emitter<QuizFourNineState> emit,
  ) async {
    emit(
      state.copyWith(
        saudiOptionController: TextEditingController(),
        emiratiOptionController: TextEditingController(),
        kuwaitiOptionController: TextEditingController(),
        bahrainiOptionController: TextEditingController(),
        qatariOptionController: TextEditingController(),
      ),
    );
  }
}
