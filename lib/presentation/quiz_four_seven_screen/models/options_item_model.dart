import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [options_item_widget] screen.

// ignore_for_file: must_be_immutable
class OptionsItemModel extends Equatable {
  OptionsItemModel({this.option, this.tf, this.id}) {
    option = option ?? "lbl_msa".tr;
    tf = tf ?? "lbl".tr;
    id = id ?? "";
  }

  String? option;

  String? tf;

  String? id;

  OptionsItemModel copyWith({
    String? option,
    String? tf,
    String? id,
  }) {
    return OptionsItemModel(
      option: option ?? this.option,
      tf: tf ?? this.tf,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [option, tf, id];
}
