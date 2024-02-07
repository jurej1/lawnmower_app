part of 'robot_path_bloc.dart';

abstract class RobotPathState {
  const RobotPathState();
}

class RobotPathLoading extends RobotPathState {}

class RobotPathSuccess extends RobotPathState {
  final List<LatLng> path;

  const RobotPathSuccess({required this.path});
}

class RobotPathFail extends RobotPathState {}
