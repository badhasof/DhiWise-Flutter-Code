import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/new_stories_model.dart';
part 'new_stories_event.dart';
part 'new_stories_state.dart';

/// A bloc that manages the state of a New Stories screen according to the event that is dispatched to it.
class NewStoriesBloc extends Bloc<NewStoriesEvent, NewStoriesState> {
  NewStoriesBloc(NewStoriesState initialState) : super(initialState) {
    on<NewStoriesInitialEvent>(_onInitialize);
  }

  _onInitialize(
    NewStoriesInitialEvent event,
    Emitter<NewStoriesState> emit,
  ) async {}
} 