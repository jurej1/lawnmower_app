part of 'robot_info_cubit.dart';

abstract class RobotInfoState extends Equatable {
  const RobotInfoState();

  @override
  List<Object> get props => [];
}

class RobotInfoLoading extends RobotInfoState {}

class RobotInfoSucess extends RobotInfoState {
  final RobotInfo robotInfo;

  const RobotInfoSucess({required this.robotInfo});
}

class RobotInfoFail extends RobotInfoState {}
