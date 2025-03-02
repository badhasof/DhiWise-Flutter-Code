import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import '../models/home_initial_model.dart';
import '../models/home_model.dart';
import '../models/home_six_item_model.dart';
part 'home_event.dart';
part 'home_state.dart';

/// A bloc that manages the state of a Home according to the event that is dispatched to it.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(HomeState initialState) : super(initialState) {
    on<HomeInitialEvent>(_onInitialize);
  }

  _onInitialize(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        homeInitialModelObj: state.homeInitialModelObj?.copyWith(
          homeSixItemList: fillHomeSixItemList(),
        ),
      ),
    );
  }

  List<HomeSixItemModel> fillHomeSixItemList() {
    return [
      HomeSixItemModel(
          labelfill: "lbl_fantasy".tr,
          hisnewbook: "msg_his_new_book_kashfal".tr,
          label: "lbl_read_now".tr,
          labelfillOne: "lbl_fantasy".tr,
          hisnewbookOne: "msg_his_new_book_kashfal".tr,
          labelOne: "lbl_read_now".tr,
          labelfillTwo: "lbl_fantasy".tr,
          hisnewbookTwo: "msg_his_new_book_kashfal".tr,
          labelTwo: "lbl_read_now".tr),
      HomeSixItemModel(
          labelfill: "lbl_fantasy".tr,
          hisnewbook: "lbl_go_to_school".tr,
          label: "lbl_read_now".tr,
          labelfillOne: "lbl_fantasy".tr,
          hisnewbookOne: "lbl_go_to_school".tr,
          labelOne: "lbl_read_now".tr,
          labelfillTwo: "lbl_fantasy".tr,
          hisnewbookTwo: "lbl_go_to_school".tr,
          labelTwo: "lbl_read_now".tr),
      HomeSixItemModel(
          labelfill: "lbl_fantasy".tr,
          hisnewbook: "msg_his_new_book_kashfal".tr,
          label: "lbl_read_now".tr,
          labelfillOne: "lbl_fantasy".tr,
          hisnewbookOne: "msg_his_new_book_kashfal".tr,
          labelOne: "lbl_read_now".tr,
          labelfillTwo: "lbl_fantasy".tr,
          hisnewbookTwo: "msg_his_new_book_kashfal".tr,
          labelTwo: "lbl_read_now".tr)
    ];
  }
}
