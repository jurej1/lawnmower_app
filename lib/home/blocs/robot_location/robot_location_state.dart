part of 'robot_location_cubit.dart';

abstract class RobotLocationState extends Equatable {
  const RobotLocationState();

  @override
  List<Object> get props => [];
}

class RobotLocationLoading extends RobotLocationState {}

class RobotLocationSuccess extends RobotLocationState {
  final LatLng robotLocation;
  final LatLng homeBase;

  const RobotLocationSuccess({required this.robotLocation, required this.homeBase});

  bool get isOnBase => robotLocation.latitude == homeBase.latitude && robotLocation.longitude == homeBase.longitude;
}

class RobotLocationFail extends RobotLocationState {}
