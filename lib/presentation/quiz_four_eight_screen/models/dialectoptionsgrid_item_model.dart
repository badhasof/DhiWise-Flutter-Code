import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [dialectoptionsgrid_item_widget] screen.

// ignore_for_file: must_be_immutable
class DialectoptionsgridItemModel extends Equatable {
  DialectoptionsgridItemModel({this.option, this.tf, this.id}) {
    option = option ?? "lbl_msa".tr;
    tf = tf ?? "lbl".tr;
    id = id ?? "";
  }

  String? option;

  String? tf;

  String? id;

  DialectoptionsgridItemModel copyWith({
    String? option,
    String? tf,
    String? id,
  }) {
    return DialectoptionsgridItemModel(
      option: option ?? this.option,
      tf: tf ?? this.tf,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [option, tf, id];
}
