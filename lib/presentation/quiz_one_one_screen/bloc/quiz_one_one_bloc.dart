import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/optionslist_item_model.dart';
import '../models/quiz_one_one_model.dart';
part 'quiz_one_one_event.dart';
part 'quiz_one_one_state.dart';

/// A bloc that manages the state of a QuizOneOne according to the event that is dispatched to it.
class QuizOneOneBloc extends Bloc<QuizOneOneEvent, QuizOneOneState> {
  QuizOneOneBloc(QuizOneOneState initialState) : super(initialState) {
    on<QuizOneOneInitialEvent>(_onInitialize);
  }

  _onInitialize(
    QuizOneOneInitialEvent event,
    Emitter<QuizOneOneState> emit,
  ) async {
    emit(
      state.copyWith(
        quizOneOneModelObj: state.quizOneOneModelObj?.copyWith(
          optionslistItemList: fillOptionslistItemList(),
        ),
      ),
    );
  }

  List<OptionslistItemModel> fillOptionslistItemList() {
    return [
      OptionslistItemModel(
          image: ImageConstant.imgUser,
          optionOne: "msg_communicate_confidently".tr),
      OptionslistItemModel(
          image: ImageConstant.imgIconBriefcase,
          optionOne: "msg_enhance_career_opportunities".tr),
      OptionslistItemModel(
          image: ImageConstant.imgIconUnion,
          optionOne: "msg_connect_with_new".tr)
    ];
  }
}
