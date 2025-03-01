import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/optionsgrid_item_model.dart';
import '../models/quiz_four_model.dart';
part 'quiz_four_event.dart';
part 'quiz_four_state.dart';

/// A bloc that manages the state of a QuizFour according to the event that is dispatched to it.
class QuizFourBloc extends Bloc<QuizFourEvent, QuizFourState> {
  QuizFourBloc(QuizFourState initialState) : super(initialState) {
    on<QuizFourInitialEvent>(_onInitialize);
    on<SelectOptionEvent>(_onSelectOption);
  }

  _onInitialize(
    QuizFourInitialEvent event,
    Emitter<QuizFourState> emit,
  ) async {
    emit(
      state.copyWith(
        quizFourModelObj: state.quizFourModelObj?.copyWith(
          optionsgridItemList: fillOptionsgridItemList(),
        ),
      ),
    );
  }

  _onSelectOption(
    SelectOptionEvent event,
    Emitter<QuizFourState> emit,
  ) {
    List<OptionsgridItemModel> optionsList = List.from(state.quizFourModelObj?.optionsgridItemList ?? []);
    
    for (var i = 0; i < optionsList.length; i++) {
      optionsList[i] = optionsList[i].copyWith(
        selected: optionsList[i].id == event.option.id,
      );
    }
    
    emit(
      state.copyWith(
        quizFourModelObj: state.quizFourModelObj?.copyWith(
          optionsgridItemList: optionsList,
        ),
        hasSelection: true,
      ),
    );
  }

  List<OptionsgridItemModel> fillOptionsgridItemList() {
    return [
      OptionsgridItemModel(
          msa: "lbl_msa".tr,
          tf: "lbl".tr,
          id: "1"),
      OptionsgridItemModel(
          msa: "lbl_eygptian".tr,
          tf: "lbl2".tr,
          id: "2"),
      OptionsgridItemModel(
          msa: "lbl_iraqi".tr,
          tf: "lbl5".tr,
          id: "3"),
      OptionsgridItemModel(
          msa: "lbl_sudanese".tr,
          tf: "msg".tr,
          id: "4"),
      OptionsgridItemModel(
          msa: "lbl_yemeni".tr,
          tf: "lbl6".tr,
          id: "5"),
      OptionsgridItemModel(
          msa: "lbl_maghrebi".tr,
          tf: "msg2".tr,
          id: "6"),
      OptionsgridItemModel(
          msa: "lbl_levantine".tr,
          tf: "lbl3".tr,
          id: "7"),
      OptionsgridItemModel(
          msa: "lbl_gulf".tr,
          tf: "lbl4".tr,
          id: "8")
    ];
  }
}
