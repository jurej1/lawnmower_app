// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'robot_info_cubit.dart';

abstract class RobotInfoState {
  const RobotInfoState();
}

class RobotInfoLoading extends RobotInfoState {}

class RobotInfoSucess extends RobotInfoState {
  final RobotInfo robotInfo;
  final bool isHybrdidEnabled;

  const RobotInfoSucess({
    required this.robotInfo,
    required this.isHybrdidEnabled,
  });
}

class RobotInfoFail extends RobotInfoState {}
