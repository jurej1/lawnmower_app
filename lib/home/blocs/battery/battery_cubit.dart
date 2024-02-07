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
      Battery battery = await _firebaseRepository.getBatteryVal();

      emit(BatterySuccess(battery: battery));
    } catch (e) {
      log(e.toString());
      emit(BatteryFail());
    }
  }
}
