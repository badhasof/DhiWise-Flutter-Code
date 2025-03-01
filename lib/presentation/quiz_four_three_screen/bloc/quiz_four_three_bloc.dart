import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/optionsgrid_item_model.dart';
import '../models/quiz_four_three_model.dart';
part 'quiz_four_three_event.dart';
part 'quiz_four_three_state.dart';

/// A bloc that manages the state of a QuizFourThree according to the event that is dispatched to it.
class QuizFourThreeBloc extends Bloc<QuizFourThreeEvent, QuizFourThreeState> {
  QuizFourThreeBloc(QuizFourThreeState initialState) : super(initialState) {
    on<QuizFourThreeInitialEvent>(_onInitialize);
  }

  _onInitialize(
    QuizFourThreeInitialEvent event,
    Emitter<QuizFourThreeState> emit,
  ) async {
    emit(
      state.copyWith(
        quizFourThreeModelObj: state.quizFourThreeModelObj?.copyWith(
          optionsgridItemList: fillOptionsgridItemList(),
        ),
      ),
    );
  }

  List<OptionsgridItemModel> fillOptionsgridItemList() {
    return [
      OptionsgridItemModel(msa: "lbl_msa".tr, tf: "lbl".tr),
      OptionsgridItemModel(msa: "lbl_eygptian".tr, tf: "lbl2".tr),
      OptionsgridItemModel(msa: "lbl_iraqi".tr, tf: "lbl5".tr),
      OptionsgridItemModel(msa: "lbl_sudanese".tr, tf: "msg".tr),
      OptionsgridItemModel(msa: "lbl_yemeni".tr, tf: "lbl6".tr),
      OptionsgridItemModel(),
      OptionsgridItemModel(),
      OptionsgridItemModel()
    ];
  }
}
