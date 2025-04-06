import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class defines the variables used in the [vocabulary_page],
/// and is typically used to hold data that is passed between different parts of the application.
class VocabularyModel extends Equatable {
  final int remainingTime;
  
  VocabularyModel({
    this.remainingTime = 0,
  });

  VocabularyModel copyWith({
    int? remainingTime,
  }) {
    return VocabularyModel(
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  @override
  List<Object?> get props => [remainingTime];
}
