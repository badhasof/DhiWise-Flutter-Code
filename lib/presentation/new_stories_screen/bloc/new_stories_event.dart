part of 'new_stories_bloc.dart';

/// Abstract class for all events that can be dispatched from the
/// New Stories widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class NewStoriesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the New Stories widget is first created.
class NewStoriesInitialEvent extends NewStoriesEvent {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the user toggles between fiction and non-fiction.
class ToggleStoryTypeEvent extends NewStoriesEvent {
  final bool isFiction;

  ToggleStoryTypeEvent({required this.isFiction});

  @override
  List<Object?> get props => [isFiction];
} 