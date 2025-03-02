import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';
import 'home_six_item_model.dart';

/// This class is used in the [home_initial_page] screen.

// ignore_for_file: must_be_immutable
class HomeInitialModel extends Equatable {
  HomeInitialModel({this.homeSixItemList = const []});

  List<HomeSixItemModel> homeSixItemList;

  HomeInitialModel copyWith({List<HomeSixItemModel>? homeSixItemList}) {
    return HomeInitialModel(
      homeSixItemList: homeSixItemList ?? this.homeSixItemList,
    );
  }

  @override
  List<Object?> get props => [homeSixItemList];
}
