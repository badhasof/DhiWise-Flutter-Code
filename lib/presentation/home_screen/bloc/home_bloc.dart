import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/home_initial_model.dart';
import '../models/home_model.dart';
import '../models/home_six_item_model.dart';
part 'home_event.dart';
part 'home_state.dart';

/// A bloc that manages the state of a Home according to the event that is dispatched to it.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(HomeState initialState) : super(initialState) {
    on<HomeInitialEvent>(_onInitialize);
  }

  _onInitialize(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        homeInitialModelObj: state.homeInitialModelObj?.copyWith(
          homeSixItemList: fillHomeSixItemList(),
        ),
      ),
    );
  }

  List<HomeSixItemModel> fillHomeSixItemList() {
    return [
      HomeSixItemModel(
          labelfill: "Stories",
          hisnewbook: "Learn Arabic Through Stories",
          label: "Start",
          labelfillOne: "Vocabulary",
          hisnewbookOne: "Essential Arabic Words",
          labelOne: "Practice",
          labelfillTwo: "Grammar",
          hisnewbookTwo: "Arabic Grammar Basics",
          labelTwo: "Learn"),
      HomeSixItemModel(
          labelfill: "Conversation",
          hisnewbook: "Daily Arabic Conversations",
          label: "Practice",
          labelfillOne: "Culture",
          hisnewbookOne: "Arabic Culture & Traditions",
          labelOne: "Explore",
          labelfillTwo: "Pronunciation",
          hisnewbookTwo: "Master Arabic Sounds",
          labelTwo: "Start"),
      HomeSixItemModel(
          labelfill: "Quizzes",
          hisnewbook: "Test Your Knowledge",
          label: "Take Quiz",
          labelfillOne: "Progress",
          hisnewbookOne: "Track Your Learning",
          labelOne: "View",
          labelfillTwo: "Community",
          hisnewbookTwo: "Connect with Learners",
          labelTwo: "Join")
    ];
  }
}
