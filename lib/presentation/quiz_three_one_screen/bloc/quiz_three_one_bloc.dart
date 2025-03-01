import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/optionslist_item_model.dart';
import '../models/quiz_three_one_model.dart';
part 'quiz_three_one_event.dart';
part 'quiz_three_one_state.dart';

/// A bloc that manages the state of a QuizThreeOne according to the event that is dispatched to it.
class QuizThreeOneBloc extends Bloc<QuizThreeOneEvent, QuizThreeOneState> {
  QuizThreeOneBloc(QuizThreeOneState initialState) : super(initialState) {
    on<QuizThreeOneInitialEvent>(_onInitialize);
  }

  _onInitialize(
    QuizThreeOneInitialEvent event,
    Emitter<QuizThreeOneState> emit,
  ) async {
    emit(
      state.copyWith(
        quizThreeOneModelObj: state.quizThreeOneModelObj?.copyWith(
          optionslistItemList: fillOptionslistItemList(),
        ),
      ),
    );
  }

  List<OptionslistItemModel> fillOptionslistItemList() {
    return [
      OptionslistItemModel(
          time: "lbl_5_10_min_day".tr,
          quickdailypract: "msg_quick_daily_practice".tr),
      OptionslistItemModel(
          time: "lbl_20_30_min_day".tr,
          quickdailypract: "lbl_steady_progress".tr),
      OptionslistItemModel(
          time: "msg_1_hour_or_more_day".tr,
          quickdailypract: "lbl_master_language".tr)
    ];
  }
}
