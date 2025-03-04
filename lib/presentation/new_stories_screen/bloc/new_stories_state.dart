part of 'new_stories_bloc.dart';

/// Represents the state of New Stories in the application.

// ignore_for_file: must_be_immutable
class NewStoriesState extends Equatable {
  NewStoriesState({this.newStoriesModelObj});

  NewStoriesModel? newStoriesModelObj;

  @override
  List<Object?> get props => [newStoriesModelObj];
  NewStoriesState copyWith({NewStoriesModel? newStoriesModelObj}) {
    return NewStoriesState(
      newStoriesModelObj: newStoriesModelObj ?? this.newStoriesModelObj,
    );
  }
} 