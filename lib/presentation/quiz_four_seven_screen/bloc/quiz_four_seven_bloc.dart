import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/options_item_model.dart';
import '../models/quiz_four_seven_model.dart';
part 'quiz_four_seven_event.dart';
part 'quiz_four_seven_state.dart';

/// A bloc that manages the state of a QuizFourSeven according to the event that is dispatched to it.
class QuizFourSevenBloc extends Bloc<QuizFourSevenEvent, QuizFourSevenState> {
  QuizFourSevenBloc(QuizFourSevenState initialState) : super(initialState) {
    on<QuizFourSevenInitialEvent>(_onInitialize);
  }

  _onInitialize(
    QuizFourSevenInitialEvent event,
    Emitter<QuizFourSevenState> emit,
  ) async {
    emit(
      state.copyWith(
        palestinianOptionController: TextEditingController(),
        syrianOptionController: TextEditingController(),
        lebaneseOptionController: TextEditingController(),
        jordanianOptionController: TextEditingController(),
      ),
    );
    emit(
      state.copyWith(
        quizFourSevenModelObj: state.quizFourSevenModelObj?.copyWith(
          optionsItemList: fillOptionsItemList(),
        ),
      ),
    );
  }

  List<OptionsItemModel> fillOptionsItemList() {
    return [
      OptionsItemModel(option: "lbl_msa".tr, tf: "lbl".tr),
      OptionsItemModel(option: "lbl_eygptian".tr, tf: "lbl2".tr),
      OptionsItemModel(option: "lbl_iraqi".tr, tf: "lbl5".tr),
      OptionsItemModel(option: "lbl_sudanese".tr, tf: "msg".tr),
      OptionsItemModel(option: "lbl_yemeni".tr, tf: "lbl6".tr),
      OptionsItemModel(),
      OptionsItemModel(),
      OptionsItemModel()
    ];
  }
}
