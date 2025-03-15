part of 'learning_bloc.dart';

/// Represents the state of Learning in the application.

// ignore_for_file: must_be_immutable
class LearningState extends Equatable {
  LearningState({this.learningModelObj});

  LearningModel? learningModelObj;

  @override
  List<Object?> get props => [learningModelObj];
  LearningState copyWith({LearningModel? learningModelObj}) {
    return LearningState(
      learningModelObj: learningModelObj ?? this.learningModelObj,
    );
  }
} 