import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_repository/firebase_repository.dart';

part 'robot_info_state.dart';

class RobotInfoCubit extends Cubit<RobotInfoState> {
  RobotInfoCubit({
    required FirebaseRepository firebaseRepository,
  })  : _firebaseRepository = firebaseRepository,
        super(RobotInfoLoading());

  final FirebaseRepository _firebaseRepository;

  Future<void> loadData() async {
    try {
      DataSnapshot snapshot = await _firebaseRepository.getRobotInfo();

      Map<String, dynamic> snapMap = (snapshot.value as Map<Object?, Object?>).cast<String, dynamic>();

      RobotInfo robotInfo = RobotInfo.fromMap(snapMap);
      emit(RobotInfoSucess(robotInfo: robotInfo));
    } catch (e) {
      log(e.toString());
      emit(RobotInfoFail());
    }
  }

  Future<void> pathDataUpdated({
    required int pathLength,
    required double area,
    required Duration duration,
  }) async {
    if (state is RobotInfoSucess) {
      try {
        final robotInfo = (state as RobotInfoSucess).robotInfo.copyWith(
              pathLength: pathLength,
              area: area,
              estimatedDuration: duration,
            );

        await _firebaseRepository.setRobotInfo(robotInfo);

        emit(RobotInfoSucess(robotInfo: robotInfo));
      } catch (e) {
        log(e.toString());
        emit(RobotInfoFail());
      }
    }
  }

  void statusSwitchUpdated(bool val) async {
    if (state is RobotInfoSucess) {
      final currentState = state as RobotInfoSucess;

      final info = currentState.robotInfo.copyWith(
        startTime: val ? DateTime.now() : null,
        status: val ? RobotStatus.mowing : RobotStatus.sleeping,
      );

      _firebaseRepository.setRobotInfo(info);

      emit(RobotInfoSucess(robotInfo: info));
    }
  }
}
