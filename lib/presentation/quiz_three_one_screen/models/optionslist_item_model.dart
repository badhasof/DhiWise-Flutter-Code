import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [optionslist_item_widget] screen.

// ignore_for_file: must_be_immutable
class OptionslistItemModel extends Equatable {
  OptionslistItemModel({this.time, this.quickdailypract, this.id}) {
    time = time ?? "lbl_5_10_min_day".tr;
    quickdailypract = quickdailypract ?? "msg_quick_daily_practice".tr;
    id = id ?? "";
  }

  String? time;

  String? quickdailypract;

  String? id;

  OptionslistItemModel copyWith({
    String? time,
    String? quickdailypract,
    String? id,
  }) {
    return OptionslistItemModel(
      time: time ?? this.time,
      quickdailypract: quickdailypract ?? this.quickdailypract,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [time, quickdailypract, id];
}
