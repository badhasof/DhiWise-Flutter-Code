import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import 'optionslist_item_model.dart';

/// This class defines the variables used in the [quiz_three_screen],
/// and is typically used to hold data that is passed between different parts of the application.

// ignore_for_file: must_be_immutable
class QuizThreeModel extends Equatable {
  QuizThreeModel({this.optionslistItemList = const []});

  List<OptionslistItemModel> optionslistItemList;

  QuizThreeModel copyWith({List<OptionslistItemModel>? optionslistItemList}) {
    return QuizThreeModel(
      optionslistItemList: optionslistItemList ?? this.optionslistItemList,
    );
  }

  @override
  List<Object?> get props => [optionslistItemList];
}
