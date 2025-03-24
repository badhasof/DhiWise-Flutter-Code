import 'package:flutter_bloc/flutter_bloc.dart';
import 'demo_time_event.dart';
import 'demo_time_state.dart';
import '../models/demo_time_model.dart';

class DemoTimeBloc extends Bloc<DemoTimeEvent, DemoTimeState> {
  DemoTimeBloc(DemoTimeState initialState) : super(initialState) {
    on<DemoTimeInitialEvent>(_onInitialize);
    on<UpdateMinutesEvent>(_onUpdateMinutes);
  }

  _onInitialize(
    DemoTimeInitialEvent event,
    Emitter<DemoTimeState> emit,
  ) {
    emit(state.copyWith(
      demoTimeModelObj: DemoTimeModel(),
    ));
  }

  _onUpdateMinutes(
    UpdateMinutesEvent event,
    Emitter<DemoTimeState> emit,
  ) {
    final updatedModel = DemoTimeModel()..selectedMinutes = event.minutes;
    emit(state.copyWith(demoTimeModelObj: updatedModel));
  }
} 