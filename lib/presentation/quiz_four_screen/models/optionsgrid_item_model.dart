import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class is used in the [optionsgrid_item_widget] screen.

// ignore_for_file: must_be_immutable
class OptionsgridItemModel extends Equatable {
  OptionsgridItemModel({
    this.msa,
    this.tf,
    this.id,
    this.selected = false,
  }) {
    msa = msa ?? "lbl_msa".tr;
    tf = tf ?? "lbl".tr;
    id = id ?? "";
  }

  String? msa;
  String? tf;
  String? id;
  bool selected;

  OptionsgridItemModel copyWith({
    String? msa,
    String? tf,
    String? id,
    bool? selected,
  }) {
    return OptionsgridItemModel(
      msa: msa ?? this.msa,
      tf: tf ?? this.tf,
      id: id ?? this.id,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [msa, tf, id, selected];
}
