part of 'vocabulary_bloc.dart';

/// Represents the state of Vocabulary in the application.

// ignore_for_file: must_be_immutable
class VocabularyState extends Equatable {
  VocabularyState({this.vocabularyModelObj});

  VocabularyModel? vocabularyModelObj;

  @override
  List<Object?> get props => [vocabularyModelObj];
  VocabularyState copyWith({VocabularyModel? vocabularyModelObj}) {
    return VocabularyState(
      vocabularyModelObj: vocabularyModelObj ?? this.vocabularyModelObj,
    );
  }
}
