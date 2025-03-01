part of 'quiz_four_ten_bloc.dart';

/// Abstract class for all events that can be dispatched from the
///QuizFourTen widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class QuizFourTenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the QuizFourTen widget is first created.
class QuizFourTenInitialEvent extends QuizFourTenEvent {
  @override
  List<Object?> get props => [];
}
