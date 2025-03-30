import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class defines the variables used in the [new_stories_page],
/// and is typically used to hold data that is passed between different parts of the application.
class NewStoriesModel extends Equatable {
  final bool isFictionSelected;

  NewStoriesModel({
    this.isFictionSelected = true,
  });

  NewStoriesModel copyWith({
    bool? isFictionSelected,
  }) {
    return NewStoriesModel(
      isFictionSelected: isFictionSelected ?? this.isFictionSelected,
    );
  }

  @override
  List<Object?> get props => [isFictionSelected];
} 