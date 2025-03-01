import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import 'optionslist_item_model.dart';

/// This class defines the variables used in the [quiz_three_one_screen],
/// and is typically used to hold data that is passed between different parts of the application.

// ignore_for_file: must_be_immutable
class QuizThreeOneModel extends Equatable {
  QuizThreeOneModel({this.optionslistItemList = const []});

  List<OptionslistItemModel> optionslistItemList;

  QuizThreeOneModel copyWith(
      {List<OptionslistItemModel>? optionslistItemList}) {
    return QuizThreeOneModel(
      optionslistItemList: optionslistItemList ?? this.optionslistItemList,
    );
  }

  @override
  List<Object?> get props => [optionslistItemList];
}
