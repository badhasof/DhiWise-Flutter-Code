import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import 'optionsgrid_item_model.dart';

/// This class defines the variables used in the [quiz_four_five_screen],
/// and is typically used to hold data that is passed between different parts of the application.

// ignore_for_file: must_be_immutable
class QuizFourFiveModel extends Equatable {
  QuizFourFiveModel({this.optionsgridItemList = const []});

  List<OptionsgridItemModel> optionsgridItemList;

  QuizFourFiveModel copyWith(
      {List<OptionsgridItemModel>? optionsgridItemList}) {
    return QuizFourFiveModel(
      optionsgridItemList: optionsgridItemList ?? this.optionsgridItemList,
    );
  }

  @override
  List<Object?> get props => [optionsgridItemList];
}
