import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
      await _firebaseRepository.setRobotInfo(
        RobotInfo(
          batteryState: 77,
          status: RobotStatus.sleeping,
          startTime: null,
          estimatedEndTime: null,
        ),
      );

      DataSnapshot snapshot = await _firebaseRepository.getRobotInfo();

      Map<String, dynamic> snapMap = (snapshot.value as Map<Object?, Object?>).cast<String, dynamic>();

      RobotInfo workData = RobotInfo.fromMap(snapMap);
      emit(RobotInfoSucess(workData: workData));
    } catch (e) {
      log(e.toString());
      emit(RobotInfoFail());
    }
  }
}
