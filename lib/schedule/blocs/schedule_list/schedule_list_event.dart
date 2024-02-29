part of 'schedule_list_bloc.dart';

abstract class ScheduleListEvent extends Equatable {
  const ScheduleListEvent();

  @override
  List<Object> get props => [];
}

class ScheduleListLoad extends ScheduleListEvent {}
