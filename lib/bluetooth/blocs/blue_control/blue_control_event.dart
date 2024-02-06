part of 'blue_control_bloc.dart';

abstract class BlueControlEvent extends Equatable {
  const BlueControlEvent();

  @override
  List<Object> get props => [];
}

class BlueControlInit extends BlueControlEvent {
  const BlueControlInit();

  @override
  List<Object> get props => [];
}

class BlueControlSetAdmin extends BlueControlEvent {}

class BlueControlNotificationDisplayUpdated extends BlueControlEvent {
  final bool val;

  const BlueControlNotificationDisplayUpdated({required this.val});

  @override
  List<Object> get props => [val];
}

class BlueControlNotificationDetected extends BlueControlEvent {
  final List<int> values;

  const BlueControlNotificationDetected({required this.values});

  @override
  List<Object> get props => [values];
}

class BlueControlSetCuttingSpeed extends BlueControlEvent {
  final double speed;

  const BlueControlSetCuttingSpeed({required this.speed});

  @override
  List<Object> get props => [speed];
}

class BlueControlSetDrivingDirection extends BlueControlEvent {
  final double x;
  final double y;

  const BlueControlSetDrivingDirection({required this.x, required this.y});

  @override
  List<Object> get props => [x, y];
}
