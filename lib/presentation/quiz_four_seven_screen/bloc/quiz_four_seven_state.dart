part of 'quiz_four_seven_bloc.dart';

/// Represents the state of QuizFourSeven in the application.

// ignore_for_file: must_be_immutable
class QuizFourSevenState extends Equatable {
  QuizFourSevenState(
      {this.palestinianOptionController,
      this.syrianOptionController,
      this.lebaneseOptionController,
      this.jordanianOptionController,
      this.quizFourSevenModelObj});

  TextEditingController? palestinianOptionController;

  TextEditingController? syrianOptionController;

  TextEditingController? lebaneseOptionController;

  TextEditingController? jordanianOptionController;

  QuizFourSevenModel? quizFourSevenModelObj;

  @override
  List<Object?> get props => [
        palestinianOptionController,
        syrianOptionController,
        lebaneseOptionController,
        jordanianOptionController,
        quizFourSevenModelObj
      ];
  QuizFourSevenState copyWith({
    TextEditingController? palestinianOptionController,
    TextEditingController? syrianOptionController,
    TextEditingController? lebaneseOptionController,
    TextEditingController? jordanianOptionController,
    QuizFourSevenModel? quizFourSevenModelObj,
  }) {
    return QuizFourSevenState(
      palestinianOptionController:
          palestinianOptionController ?? this.palestinianOptionController,
      syrianOptionController:
          syrianOptionController ?? this.syrianOptionController,
      lebaneseOptionController:
          lebaneseOptionController ?? this.lebaneseOptionController,
      jordanianOptionController:
          jordanianOptionController ?? this.jordanianOptionController,
      quizFourSevenModelObj:
          quizFourSevenModelObj ?? this.quizFourSevenModelObj,
    );
  }
}
