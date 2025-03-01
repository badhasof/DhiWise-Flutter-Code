import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import 'optionslist_item_model.dart';

/// This class defines the variables used in the [quiz_two_one_screen],
/// and is typically used to hold data that is passed between different parts of the application.

// ignore_for_file: must_be_immutable
class QuizTwoOneModel extends Equatable {
  QuizTwoOneModel({this.optionslistItemList = const []});

  List<OptionslistItemModel> optionslistItemList;

  QuizTwoOneModel copyWith({List<OptionslistItemModel>? optionslistItemList}) {
    return QuizTwoOneModel(
      optionslistItemList: optionslistItemList ?? this.optionslistItemList,
    );
  }

  @override
  List<Object?> get props => [optionslistItemList];
}
