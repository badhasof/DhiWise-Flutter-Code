import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/optionslist_item_model.dart';
import '../models/quiz_three_model.dart';
part 'quiz_three_event.dart';
part 'quiz_three_state.dart';

/// A bloc that manages the state of a QuizThree according to the event that is dispatched to it.
class QuizThreeBloc extends Bloc<QuizThreeEvent, QuizThreeState> {
  QuizThreeBloc(QuizThreeState initialState) : super(initialState) {
    on<QuizThreeInitialEvent>(_onInitialize);
    on<SelectOptionEvent>(_onSelectOption);
  }

  _onInitialize(
    QuizThreeInitialEvent event,
    Emitter<QuizThreeState> emit,
  ) async {
    emit(
      state.copyWith(
        quizThreeModelObj: state.quizThreeModelObj?.copyWith(
          optionslistItemList: fillOptionslistItemList(),
        ),
      ),
    );
  }

  _onSelectOption(
    SelectOptionEvent event,
    Emitter<QuizThreeState> emit,
  ) {
    List<OptionslistItemModel> optionsList = List.from(state.quizThreeModelObj?.optionslistItemList ?? []);
    
    for (var i = 0; i < optionsList.length; i++) {
      optionsList[i] = optionsList[i].copyWith(
        selected: optionsList[i].id == event.option.id,
      );
    }
    
    emit(
      state.copyWith(
        quizThreeModelObj: state.quizThreeModelObj?.copyWith(
          optionslistItemList: optionsList,
        ),
        hasSelection: true,
      ),
    );
  }

  List<OptionslistItemModel> fillOptionslistItemList() {
    return [
      OptionslistItemModel(
          image: ImageConstant.imgUser,
          optionOne: "5-10 min/day",
          id: "1"),
      OptionslistItemModel(
          image: ImageConstant.imgIconBriefcase,
          optionOne: "15-20 min/day",
          id: "2"),
      OptionslistItemModel(
          image: ImageConstant.imgIconUnion,
          optionOne: "30+ min/day",
          id: "3")
    ];
  }
}
