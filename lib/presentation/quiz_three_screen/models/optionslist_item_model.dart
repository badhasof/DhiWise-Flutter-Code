import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [optionslist_item_widget] screen.

// ignore_for_file: must_be_immutable
class OptionslistItemModel extends Equatable {
  OptionslistItemModel({
    this.image,
    this.optionOne,
    this.id,
    this.selected = false,
  }) {
    image = image ?? ImageConstant.imgUser;
    optionOne = optionOne ?? "msg_communicate_confidently".tr;
    id = id ?? "";
  }

  String? image;
  String? optionOne;
  String? id;
  bool selected;

  OptionslistItemModel copyWith({
    String? image,
    String? optionOne,
    String? id,
    bool? selected,
  }) {
    return OptionslistItemModel(
      image: image ?? this.image,
      optionOne: optionOne ?? this.optionOne,
      id: id ?? this.id,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [image, optionOne, id, selected];
}
