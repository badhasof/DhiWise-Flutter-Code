import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import 'options_item_model.dart';

/// This class defines the variables used in the [quiz_four_seven_screen],
/// and is typically used to hold data that is passed between different parts of the application.

// ignore_for_file: must_be_immutable
class QuizFourSevenModel extends Equatable {
  QuizFourSevenModel({this.optionsItemList = const []});

  List<OptionsItemModel> optionsItemList;

  QuizFourSevenModel copyWith({List<OptionsItemModel>? optionsItemList}) {
    return QuizFourSevenModel(
      optionsItemList: optionsItemList ?? this.optionsItemList,
    );
  }

  @override
  List<Object?> get props => [optionsItemList];
}
