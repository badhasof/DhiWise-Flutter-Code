import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/optionslist_item_model.dart';
import '../models/quiz_two_model.dart';
part 'quiz_two_event.dart';
part 'quiz_two_state.dart';

/// A bloc that manages the state of a QuizTwo according to the event that is dispatched to it.
class QuizTwoBloc extends Bloc<QuizTwoEvent, QuizTwoState> {
  QuizTwoBloc(QuizTwoState initialState) : super(initialState) {
    on<QuizTwoInitialEvent>(_onInitialize);
    on<SelectOptionEvent>(_onSelectOption);
  }

  _onInitialize(
    QuizTwoInitialEvent event,
    Emitter<QuizTwoState> emit,
  ) async {
    emit(
      state.copyWith(
        quizTwoModelObj: state.quizTwoModelObj?.copyWith(
          optionslistItemList: fillOptionslistItemList(),
        ),
      ),
    );
  }

  _onSelectOption(
    SelectOptionEvent event,
    Emitter<QuizTwoState> emit,
  ) {
    List<OptionslistItemModel> optionsList = List.from(state.quizTwoModelObj?.optionslistItemList ?? []);
    
    for (var i = 0; i < optionsList.length; i++) {
      optionsList[i] = optionsList[i].copyWith(
        selected: optionsList[i].id == event.option.id,
      );
    }
    
    emit(
      state.copyWith(
        quizTwoModelObj: state.quizTwoModelObj?.copyWith(
          optionslistItemList: optionsList,
        ),
        hasSelection: true,
      ),
    );
  }

  List<OptionslistItemModel> fillOptionslistItemList() {
    return [
      OptionslistItemModel(
          image: ImageConstant.imgSettings,
          optionOne: "msg_pronunciation".tr,
          id: "1"),
      OptionslistItemModel(
          image: ImageConstant.imgUserBlueA400,
          optionOne: "msg_speaking_fluency".tr,
          id: "2"),
      OptionslistItemModel(
          image: ImageConstant.imgThumbsUp,
          optionOne: "msg_culture_conversations".tr,
          id: "3")
    ];
  }
}
