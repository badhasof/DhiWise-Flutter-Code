import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/optionsgrid_item_model.dart';
import '../models/quiz_four_ten_model.dart';
part 'quiz_four_ten_event.dart';
part 'quiz_four_ten_state.dart';

/// A bloc that manages the state of a QuizFourTen according to the event that is dispatched to it.
class QuizFourTenBloc extends Bloc<QuizFourTenEvent, QuizFourTenState> {
  QuizFourTenBloc(QuizFourTenState initialState) : super(initialState) {
    on<QuizFourTenInitialEvent>(_onInitialize);
  }

  _onInitialize(
    QuizFourTenInitialEvent event,
    Emitter<QuizFourTenState> emit,
  ) async {
    emit(
      state.copyWith(
        quizFourTenModelObj: state.quizFourTenModelObj?.copyWith(
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
