import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/optionslist_item_model.dart';
import '../models/quiz_one_model.dart';
part 'quiz_one_event.dart';
part 'quiz_one_state.dart';

/// A bloc that manages the state of a QuizOne according to the event that is dispatched to it.
class QuizOneBloc extends Bloc<QuizOneEvent, QuizOneState> {
  QuizOneBloc(QuizOneState initialState) : super(initialState) {
    on<QuizOneInitialEvent>(_onInitialize);
    on<SelectOptionEvent>(_onSelectOption);
  }

  _onInitialize(
    QuizOneInitialEvent event,
    Emitter<QuizOneState> emit,
  ) async {
    emit(
      state.copyWith(
        quizOneModelObj: state.quizOneModelObj?.copyWith(
          optionslistItemList: fillOptionslistItemList(),
        ),
      ),
    );
  }

  _onSelectOption(
    SelectOptionEvent event,
    Emitter<QuizOneState> emit,
  ) {
    print("SelectOptionEvent received: ${event.option.id}");
    
    List<OptionslistItemModel> optionsList = List.from(state.quizOneModelObj?.optionslistItemList ?? []);
    
    for (var i = 0; i < optionsList.length; i++) {
      optionsList[i] = optionsList[i].copyWith(
        selected: optionsList[i].id == event.option.id,
      );
      print("Option ${optionsList[i].id} selected: ${optionsList[i].selected}");
    }
    
    final newState = state.copyWith(
      quizOneModelObj: state.quizOneModelObj?.copyWith(
        optionslistItemList: optionsList,
      ),
      hasSelection: true,
    );
    
    print("Emitting new state");
    emit(newState);
  }

  List<OptionslistItemModel> fillOptionslistItemList() {
    return [
      OptionslistItemModel(
          image: ImageConstant.imgUser,
          optionOne: "msg_communicate_confidently".tr,
          id: "1"),
      OptionslistItemModel(
          image: ImageConstant.imgIconBriefcase,
          optionOne: "msg_enhance_career_opportunities".tr,
          id: "2"),
      OptionslistItemModel(
          image: ImageConstant.imgIconUnion,
          optionOne: "msg_connect_with_new".tr,
          id: "3")
    ];
  }
}
