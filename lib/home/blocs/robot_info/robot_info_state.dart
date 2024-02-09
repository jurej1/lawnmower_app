part of 'robot_info_cubit.dart';

abstract class RobotInfoState {
  const RobotInfoState();
}

class RobotInfoLoading extends RobotInfoState {}

class RobotInfoSucess extends RobotInfoState {
  final RobotInfo robotInfo;

  const RobotInfoSucess({required this.robotInfo});
}

class RobotInfoFail extends RobotInfoState {}
