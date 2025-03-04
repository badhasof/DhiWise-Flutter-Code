import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [home_six_item_widget] screen.

// ignore_for_file: must_be_immutable
class HomeSixItemModel extends Equatable {
  HomeSixItemModel(
      {this.labelfill,
      this.hisnewbook,
      this.label,
      this.labelfillOne,
      this.hisnewbookOne,
      this.labelOne,
      this.labelfillTwo,
      this.hisnewbookTwo,
      this.labelTwo,
      this.id}) {
    labelfill = labelfill ?? "lbl_fantasy".tr;
    hisnewbook = hisnewbook ?? "msg_his_new_book_kashfal".tr;
    label = label ?? "lbl_read_now".tr;
    labelfillOne = labelfillOne ?? "lbl_fantasy".tr;
    hisnewbookOne = hisnewbookOne ?? "msg_his_new_book_kashfal".tr;
    labelOne = labelOne ?? "lbl_read_now".tr;
    labelfillTwo = labelfillTwo ?? "lbl_fantasy".tr;
    hisnewbookTwo = hisnewbookTwo ?? "msg_his_new_book_kashfal".tr;
    labelTwo = labelTwo ?? "lbl_read_now".tr;
    id = id ?? "";
  }

  String? labelfill;

  String? hisnewbook;

  String? label;

  String? labelfillOne;

  String? hisnewbookOne;

  String? labelOne;

  String? labelfillTwo;

  String? hisnewbookTwo;

  String? labelTwo;

  String? id;

  HomeSixItemModel copyWith({
    String? labelfill,
    String? hisnewbook,
    String? label,
    String? labelfillOne,
    String? hisnewbookOne,
    String? labelOne,
    String? labelfillTwo,
    String? hisnewbookTwo,
    String? labelTwo,
    String? id,
  }) {
    return HomeSixItemModel(
      labelfill: labelfill ?? this.labelfill,
      hisnewbook: hisnewbook ?? this.hisnewbook,
      label: label ?? this.label,
      labelfillOne: labelfillOne ?? this.labelfillOne,
      hisnewbookOne: hisnewbookOne ?? this.hisnewbookOne,
      labelOne: labelOne ?? this.labelOne,
      labelfillTwo: labelfillTwo ?? this.labelfillTwo,
      hisnewbookTwo: hisnewbookTwo ?? this.hisnewbookTwo,
      labelTwo: labelTwo ?? this.labelTwo,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [
        labelfill,
        hisnewbook,
        label,
        labelfillOne,
        hisnewbookOne,
        labelOne,
        labelfillTwo,
        hisnewbookTwo,
        labelTwo,
        id
      ];
}
