part of 'schedule_form_bloc.dart';

sealed class ScheduleFormEvent extends Equatable {
  const ScheduleFormEvent();

  @override
  List<Object> get props => [];
}

class ScheduleFormDateUpdated extends ScheduleFormEvent {
  final DateTime date;

  const ScheduleFormDateUpdated({required this.date});
}

class ScheduleFormTimeUpdated extends ScheduleFormEvent {
  final TimeOfDay timeOfDay;

  const ScheduleFormTimeUpdated({required this.timeOfDay});
}

class ScheduleFormSubmit extends ScheduleFormEvent {}
