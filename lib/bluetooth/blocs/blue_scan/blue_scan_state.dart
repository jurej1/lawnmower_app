// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'blue_scan_cubit.dart';

class BlueScanState {
  const BlueScanState([this.devices = const []]);

  final List<BluetoothDevice> devices;

  BlueScanState copyWith({
    List<BluetoothDevice>? devices,
  }) {
    return BlueScanState(
      devices ?? this.devices,
    );
  }
}
