part of 'battery_cubit.dart';

abstract class BatteryState extends Equatable {
  const BatteryState();

  @override
  List<Object> get props => [];
}

class BatteryLoading extends BatteryState {}

class BatterySuccess extends BatteryState {
  final Battery battery;

  const BatterySuccess({required this.battery});
}

class BatteryFail extends BatteryState {}
