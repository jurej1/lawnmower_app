part of 'schedule_form_bloc.dart';

sealed class ScheduleFormState extends Equatable {
  const ScheduleFormState();
  
  @override
  List<Object> get props => [];
}

final class ScheduleFormInitial extends ScheduleFormState {}
