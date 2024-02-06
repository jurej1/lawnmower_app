part of 'blue_control_bloc.dart';

enum BlueConnectionStatus {
  connected,
  loading,
  disconnected,
}

class BlueControlState extends Equatable {
  const BlueControlState(
    this.device, {
    this.status = BlueConnectionStatus.loading,
    this.writeCharacteristic,
    this.cuttingSpeed = 0.0,
    this.notificationMessage = "",
    this.hasNotificationBeenShown = true,
    this.isUserControlingIt = false,
  });

  final BluetoothDevice device;
  final BlueConnectionStatus status;
  final BluetoothCharacteristic? writeCharacteristic;

  final double cuttingSpeed;

  final String notificationMessage;
  final bool hasNotificationBeenShown;
  final bool isUserControlingIt;

  @override
  List<Object?> get props => [
        device,
        status,
        writeCharacteristic,
        cuttingSpeed,
        notificationMessage,
        hasNotificationBeenShown,
        isUserControlingIt,
      ];

  BlueControlState copyWith(
      {BluetoothDevice? device,
      BlueConnectionStatus? status,
      BluetoothCharacteristic? writeCharacteristic,
      double? cuttingSpeed,
      String? notificationMessage,
      bool? hasNotificationBeenShown,
      bool? isUserControlingIt}) {
    return BlueControlState(
      device ?? this.device,
      status: status ?? this.status,
      writeCharacteristic: writeCharacteristic ?? this.writeCharacteristic,
      cuttingSpeed: cuttingSpeed ?? this.cuttingSpeed,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      hasNotificationBeenShown: hasNotificationBeenShown ?? this.hasNotificationBeenShown,
      isUserControlingIt: isUserControlingIt ?? this.isUserControlingIt,
    );
  }

  bool get isCharacteristicLoaded => writeCharacteristic != null;
}
