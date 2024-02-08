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

class BlueControlUpwardPressed extends BlueControlEvent {
  const BlueControlUpwardPressed();
}

class BlueControlDownwardPressed extends BlueControlEvent {
  const BlueControlDownwardPressed();
}

class BlueControlLeftPressed extends BlueControlEvent {
  const BlueControlLeftPressed();
}

class BlueControlRightPressed extends BlueControlEvent {
  const BlueControlRightPressed();
}
