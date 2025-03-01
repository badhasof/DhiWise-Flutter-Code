import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [optionslist_item_widget] screen.

// ignore_for_file: must_be_immutable
class OptionslistItemModel extends Equatable {
  OptionslistItemModel({this.image, this.optionOne, this.id}) {
    image = image ?? ImageConstant.imgUser;
    optionOne = optionOne ?? "msg_communicate_confidently".tr;
    id = id ?? "";
  }

  String? image;

  String? optionOne;

  String? id;

  OptionslistItemModel copyWith({
    String? image,
    String? optionOne,
    String? id,
  }) {
    return OptionslistItemModel(
      image: image ?? this.image,
      optionOne: optionOne ?? this.optionOne,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [image, optionOne, id];
}
