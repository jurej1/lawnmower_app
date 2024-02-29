import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:lawnmower_app/schedule/models/date_input.dart';

part 'schedule_form_event.dart';
part 'schedule_form_state.dart';

class ScheduleFormBloc extends Bloc<ScheduleFormEvent, ScheduleFormState> {
  ScheduleFormBloc()
      : super(
          ScheduleFormState(
            dateInput: DateInput.pure(DateTime.now().add(const Duration(hours: 1))),
            status: FormzSubmissionStatus.initial,
          ),
        ) {}
}
