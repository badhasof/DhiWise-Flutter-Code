import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/dialectoptionsgrid_item_model.dart';
import '../models/quiz_four_eight_model.dart';
part 'quiz_four_eight_event.dart';
part 'quiz_four_eight_state.dart';

/// A bloc that manages the state of a QuizFourEight according to the event that is dispatched to it.
class QuizFourEightBloc extends Bloc<QuizFourEightEvent, QuizFourEightState> {
  QuizFourEightBloc(QuizFourEightState initialState) : super(initialState) {
    on<QuizFourEightInitialEvent>(_onInitialize);
  }

  _onInitialize(
    QuizFourEightInitialEvent event,
    Emitter<QuizFourEightState> emit,
  ) async {
    emit(
      state.copyWith(
        quizFourEightModelObj: state.quizFourEightModelObj?.copyWith(
          dialectoptionsgridItemList: fillDialectoptionsgridItemList(),
        ),
      ),
    );
  }

  List<DialectoptionsgridItemModel> fillDialectoptionsgridItemList() {
    return [
      DialectoptionsgridItemModel(option: "lbl_msa".tr, tf: "lbl".tr),
      DialectoptionsgridItemModel(option: "lbl_eygptian".tr, tf: "lbl2".tr),
      DialectoptionsgridItemModel(option: "lbl_iraqi".tr, tf: "lbl5".tr),
      DialectoptionsgridItemModel(option: "lbl_sudanese".tr, tf: "msg".tr),
      DialectoptionsgridItemModel(option: "lbl_yemeni".tr, tf: "lbl6".tr),
      DialectoptionsgridItemModel(),
      DialectoptionsgridItemModel(),
      DialectoptionsgridItemModel(),
      DialectoptionsgridItemModel()
    ];
  }
}
