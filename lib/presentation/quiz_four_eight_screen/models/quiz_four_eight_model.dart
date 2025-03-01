import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import 'dialectoptionsgrid_item_model.dart';

/// This class defines the variables used in the [quiz_four_eight_screen],
/// and is typically used to hold data that is passed between different parts of the application.

// ignore_for_file: must_be_immutable
class QuizFourEightModel extends Equatable {
  QuizFourEightModel({this.dialectoptionsgridItemList = const []});

  List<DialectoptionsgridItemModel> dialectoptionsgridItemList;

  QuizFourEightModel copyWith(
      {List<DialectoptionsgridItemModel>? dialectoptionsgridItemList}) {
    return QuizFourEightModel(
      dialectoptionsgridItemList:
          dialectoptionsgridItemList ?? this.dialectoptionsgridItemList,
    );
  }

  @override
  List<Object?> get props => [dialectoptionsgridItemList];
}
