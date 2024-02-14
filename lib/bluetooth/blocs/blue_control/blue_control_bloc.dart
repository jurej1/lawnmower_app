import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'blue_control_event.dart';
part 'blue_control_state.dart';

class BlueControlBloc extends Bloc<BlueControlEvent, BlueControlState> {
  BlueControlBloc(BluetoothDevice device) : super(BlueControlState(device)) {
    on<BlueControlInit>(_mapInitToState);
    on<BlueControlSetCuttingSpeed>(_mapSetCuttingSpeedToState);
    on<BlueControlSetAdmin>(_mapSetAdminToState);
    on<BlueControlNotificationDetected>(_mapNotificationToState);
    on<BlueControlNotificationDisplayUpdated>(_mapNotificationDisplayUpdatedToState);

    // Controls
    on<BlueControlUpwardPressed>(_mapUpwardToState);
    on<BlueControlDownwardPressed>(_mapDownwardToState);
    on<BlueControlLeftPressed>(_mapLeftToState);
    on<BlueControlRightPressed>(_mapRightToState);
  }

  StreamSubscription<List<int>>? listenSubscription;

  FutureOr<void> _mapInitToState(BlueControlInit event, Emitter<BlueControlState> emit) async {
    try {
      emit(state.copyWith(status: BlueConnectionStatus.loading));
      await state.device.connect(mtu: 138);
      await state.device.requestConnectionPriority(connectionPriorityRequest: ConnectionPriority.high);
      emit(state.copyWith(status: BlueConnectionStatus.connected));

      final List<BluetoothService> blueServices = await state.device.discoverServices();
      final BluetoothService customService = blueServices.firstWhere((element) => element.serviceUuid.str == "ffe0");
      final BluetoothCharacteristic characteristic = customService.characteristics.first;
      await characteristic.setNotifyValue(true); // Enable notiffying

      listenSubscription = characteristic.onValueReceived.listen((value) {
        add(BlueControlNotificationDetected(values: value));
      });

      emit(state.copyWith(writeCharacteristic: characteristic));
      add(BlueControlSetAdmin());
    } on Exception catch (e) {
      log(e.toString());
      emit(state.copyWith(status: BlueConnectionStatus.disconnected));
    }
  }

  FutureOr<void> _mapSetCuttingSpeedToState(BlueControlSetCuttingSpeed event, Emitter<BlueControlState> emit) async {
    try {
      if (state.isCharacteristicLoaded) {
        String textToSend = "CutSpeed:${event.speed.floor()}";
        List<int> data = utf8.encode(textToSend);
        emit(state.copyWith(cuttingSpeed: event.speed));
        await state.writeCharacteristic!.write(data, withoutResponse: true);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  FutureOr<void> _mapSetAdminToState(BlueControlSetAdmin event, Emitter<BlueControlState> emit) async {
    try {
      if (state.isCharacteristicLoaded) {
        String textToSend = "Admin:User";
        List<int> data = utf8.encode(textToSend);
        await state.writeCharacteristic!.write(data, withoutResponse: true);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  FutureOr<void> _mapNotificationToState(BlueControlNotificationDetected event, Emitter<BlueControlState> emit) {
    final String msg = utf8.decode(event.values);

    log("MSG1: ${event.values}");
    log("MSG2: $msg");

    if (msg.isNotEmpty) {
      if (msg == "msg111") {
        emit(
          state.copyWith(
            notificationMessage: "You are now successfully controling Rasenrobotoer",
            hasNotificationBeenShown: false,
            isUserControlingIt: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            notificationMessage: msg,
            hasNotificationBeenShown: false,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    if (listenSubscription != null) state.device.cancelWhenDisconnected(listenSubscription!);
    listenSubscription?.cancel();
    await state.device.disconnect();
    return super.close();
  }

  FutureOr<void> _mapNotificationDisplayUpdatedToState(BlueControlNotificationDisplayUpdated event, Emitter<BlueControlState> emit) {
    emit(state.copyWith(hasNotificationBeenShown: event.val));
  }

  FutureOr<void> _mapUpwardToState(BlueControlUpwardPressed event, Emitter<BlueControlState> emit) async {
    try {
      if (state.isCharacteristicLoaded) {
        String textToSend = "Dir: { \"x\": 100, \"y\": 0 }";
        List<int> data = utf8.encode(textToSend);
        await state.writeCharacteristic!.write(data, withoutResponse: true);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  FutureOr<void> _mapDownwardToState(BlueControlDownwardPressed event, Emitter<BlueControlState> emit) async {
    try {
      if (state.isCharacteristicLoaded) {
        String textToSend = "Dir: { \"x\": -100, \"y\": 0 }";
        List<int> data = utf8.encode(textToSend);
        await state.writeCharacteristic!.write(data, withoutResponse: true);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  FutureOr<void> _mapLeftToState(BlueControlLeftPressed event, Emitter<BlueControlState> emit) async {
    try {
      if (state.isCharacteristicLoaded) {
        String textToSend = "Dir: { \"x\": 0, \"y\": -100 }";
        List<int> data = utf8.encode(textToSend);
        await state.writeCharacteristic!.write(data, withoutResponse: true);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  FutureOr<void> _mapRightToState(event, Emitter<BlueControlState> emit) async {
    try {
      if (state.isCharacteristicLoaded) {
        String textToSend = "Dir: { \"x\": 0, \"y\": 100 }";
        List<int> data = utf8.encode(textToSend);
        await state.writeCharacteristic!.write(data, withoutResponse: true);
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
