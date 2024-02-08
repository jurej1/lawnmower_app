import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'blue_scan_state.dart';

class BlueScanCubit extends Cubit<BlueScanState> {
  BlueScanCubit() : super(const BlueScanState());

  void startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 2));
    final subscription = FlutterBluePlus.onScanResults.listen((data) {
      emit(BlueScanState(data.map((e) => e.device).toList()));
    });

    FlutterBluePlus.cancelWhenScanComplete(subscription);
  }
}
