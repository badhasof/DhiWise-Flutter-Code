import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/optionslist_item_model.dart';
import '../models/quiz_two_one_model.dart';
part 'quiz_two_one_event.dart';
part 'quiz_two_one_state.dart';

/// A bloc that manages the state of a QuizTwoOne according to the event that is dispatched to it.
class QuizTwoOneBloc extends Bloc<QuizTwoOneEvent, QuizTwoOneState> {
  QuizTwoOneBloc(QuizTwoOneState initialState) : super(initialState) {
    on<QuizTwoOneInitialEvent>(_onInitialize);
  }

  _onInitialize(
    QuizTwoOneInitialEvent event,
    Emitter<QuizTwoOneState> emit,
  ) async {
    emit(
      state.copyWith(
        quizTwoOneModelObj: state.quizTwoOneModelObj?.copyWith(
          optionslistItemList: fillOptionslistItemList(),
        ),
      ),
    );
  }

  List<OptionslistItemModel> fillOptionslistItemList() {
    return [
      OptionslistItemModel(
          image: ImageConstant.imgSettings, optionOne: "msg_pronunciation".tr),
      OptionslistItemModel(
          image: ImageConstant.imgUserBlueA400,
          optionOne: "msg_speaking_fluency".tr),
      OptionslistItemModel(
          image: ImageConstant.imgThumbsUp,
          optionOne: "msg_culture_conversations".tr)
    ];
  }
}
