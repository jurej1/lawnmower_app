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

  void loadData() async {
    try {
      DataSnapshot snapshot = await _firebaseRepository.getRobotInfo();

      Map<String, dynamic> snapMap = (snapshot.value as Map<Object?, Object?>).cast<String, dynamic>();

      RobotInfo workData = RobotInfo.fromMap(snapMap);
      emit(RobotInfoSucess(robotInfo: workData));
    } catch (e) {
      log(e.toString());
      emit(RobotInfoFail());
    }
  }

  void statusSwitchUpdated(bool val) async {
    if (state is RobotInfoSucess) {
      final currentState = state as RobotInfoSucess;

      final info = currentState.robotInfo.copyWith(
        startTime: DateTime.now(),
        status: val ? RobotStatus.mowing : RobotStatus.sleeping,
      );

      _firebaseRepository.setRobotInfo(info);

      emit(RobotInfoSucess(robotInfo: info));
    }
  }
}
