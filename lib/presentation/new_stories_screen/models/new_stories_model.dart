import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class defines the variables used in the [new_stories_page],
/// and is typically used to hold data that is passed between different parts of the application.
class NewStoriesModel extends Equatable {
  NewStoriesModel();

  NewStoriesModel copyWith() {
    return NewStoriesModel();
  }

  @override
  List<Object?> get props => [];
} 