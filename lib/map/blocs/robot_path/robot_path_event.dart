part of 'robot_path_bloc.dart';

abstract class RobotPathEvent extends Equatable {
  const RobotPathEvent();

  @override
  List<Object> get props => [];
}

class RobotPathMarkersUpdated extends RobotPathEvent {
  final List<MarkerShort> markers;

  const RobotPathMarkersUpdated({required this.markers});
}
