import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/vocabulary_model.dart';
part 'vocabulary_event.dart';
part 'vocabulary_state.dart';

/// A bloc that manages the state of a Vocabulary according to the event that is dispatched to it.
class VocabularyBloc extends Bloc<VocabularyEvent, VocabularyState> {
  VocabularyBloc(VocabularyState initialState) : super(initialState) {
    on<VocabularyInitialEvent>(_onInitialize);
  }

  _onInitialize(
    VocabularyInitialEvent event,
    Emitter<VocabularyState> emit,
  ) async {}
}
