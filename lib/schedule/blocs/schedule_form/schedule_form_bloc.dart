import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'schedule_form_event.dart';
part 'schedule_form_state.dart';

class ScheduleFormBloc extends Bloc<ScheduleFormEvent, ScheduleFormState> {
  ScheduleFormBloc() : super(ScheduleFormInitial()) {
    on<ScheduleFormEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
