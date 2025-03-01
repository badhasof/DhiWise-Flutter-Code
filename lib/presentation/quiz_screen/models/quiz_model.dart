import 'package:equatable/equatable.dart';
import '../../../core/app_export.dart';

/// This class defines the variables used in the [quiz_screen],
/// and is typically used to hold data that is passed between different parts of the application.
class QuizModel extends Equatable {
  QuizModel();

  QuizModel copyWith() {
    return QuizModel();
  }

  @override
  List<Object?> get props => [];
}
