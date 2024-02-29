part of 'schedule_list_bloc.dart';

abstract class ScheduleListState extends Equatable {
  const ScheduleListState();

  @override
  List<Object> get props => [];
}

class ScheduleListLoading extends ScheduleListState {}

class ScheduleListSuccess extends ScheduleListState {
  final List<Schedule> schedules;

  const ScheduleListSuccess({required this.schedules});
}

class ScheduleListFail extends ScheduleListState {}
