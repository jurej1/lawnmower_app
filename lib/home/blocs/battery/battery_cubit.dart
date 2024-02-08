import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'battery_state.dart';

class BatteryCubit extends Cubit<BatteryState> {
  BatteryCubit({
    required FirebaseRepository firebaseRepository,
  })  : _firebaseRepository = firebaseRepository,
        super(BatteryLoading());

  final FirebaseRepository _firebaseRepository;

  void loadData() async {
    try {
      final snapshot = await _firebaseRepository.getBatteryVal();

      Map<String, dynamic> value = (snapshot.value as Map<Object?, Object?>).cast<String, dynamic>();
      Battery battery = Battery.fromMap(value);

      emit(BatterySuccess(battery: battery));
    } catch (e) {
      log(e.toString());
      emit(BatteryFail());
    }
  }
}
