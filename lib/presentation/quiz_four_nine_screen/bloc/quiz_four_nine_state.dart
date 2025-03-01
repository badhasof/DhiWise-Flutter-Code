part of 'quiz_four_nine_bloc.dart';

/// Represents the state of QuizFourNine in the application.

// ignore_for_file: must_be_immutable
class QuizFourNineState extends Equatable {
  QuizFourNineState(
      {this.saudiOptionController,
      this.emiratiOptionController,
      this.kuwaitiOptionController,
      this.bahrainiOptionController,
      this.qatariOptionController,
      this.quizFourNineModelObj});

  TextEditingController? saudiOptionController;

  TextEditingController? emiratiOptionController;

  TextEditingController? kuwaitiOptionController;

  TextEditingController? bahrainiOptionController;

  TextEditingController? qatariOptionController;

  QuizFourNineModel? quizFourNineModelObj;

  @override
  List<Object?> get props => [
        saudiOptionController,
        emiratiOptionController,
        kuwaitiOptionController,
        bahrainiOptionController,
        qatariOptionController,
        quizFourNineModelObj
      ];
  QuizFourNineState copyWith({
    TextEditingController? saudiOptionController,
    TextEditingController? emiratiOptionController,
    TextEditingController? kuwaitiOptionController,
    TextEditingController? bahrainiOptionController,
    TextEditingController? qatariOptionController,
    QuizFourNineModel? quizFourNineModelObj,
  }) {
    return QuizFourNineState(
      saudiOptionController:
          saudiOptionController ?? this.saudiOptionController,
      emiratiOptionController:
          emiratiOptionController ?? this.emiratiOptionController,
      kuwaitiOptionController:
          kuwaitiOptionController ?? this.kuwaitiOptionController,
      bahrainiOptionController:
          bahrainiOptionController ?? this.bahrainiOptionController,
      qatariOptionController:
          qatariOptionController ?? this.qatariOptionController,
      quizFourNineModelObj: quizFourNineModelObj ?? this.quizFourNineModelObj,
    );
  }
}
