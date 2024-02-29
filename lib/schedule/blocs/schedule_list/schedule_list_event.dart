part of 'schedule_list_bloc.dart';

abstract class ScheduleListEvent extends Equatable {
  const ScheduleListEvent();

  @override
  List<Object> get props => [];
}

class ScheduleListLoad extends ScheduleListEvent {}

class ScheduleListItemAdded extends ScheduleListEvent {
  final Schedule schedule;

  const ScheduleListItemAdded({required this.schedule});
}
