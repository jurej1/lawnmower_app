import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_repository/firebase_repository.dart';

part 'robot_info_state.dart';

class RobotInfoCubit extends Cubit<RobotInfoState> {
  RobotInfoCubit({
    required FirebaseRepository firebaseRepository,
  })  : _firebaseRepository = firebaseRepository,
        super(RobotInfoLoading()) {
    _startListening();
  }

  final FirebaseRepository _firebaseRepository;
  StreamSubscription<DataSnapshot>? _robotInfoSubscription;

  void _startListening() {
    _robotInfoSubscription = _firebaseRepository.robotInfoListener().listen(
      (DataSnapshot snapshot) {
        if (snapshot.value != null) {
          try {
            final currentState = state;

            Map<String, dynamic> snapMap = (snapshot.value as Map<Object?, Object?>).cast<String, dynamic>();
            RobotInfo robotInfo = RobotInfo.fromMap(snapMap);
            final isHybrid = (currentState is RobotInfoSucess) ? (currentState).isHybrdidEnabled : robotInfo.status.isMowingHybrid;
            emit(
              RobotInfoSucess(
                robotInfo: robotInfo,
                isHybrdidEnabled: isHybrid,
              ),
            );
          } catch (e) {
            log(e.toString());
            emit(RobotInfoFail());
          }
        }
      },
      onError: (error) {
        log(error.toString());
        emit(RobotInfoFail());
      },
    );
  }

  Future<void> loadData() async {
    try {
      DataSnapshot snapshot = await _firebaseRepository.getRobotInfo();
      final currentState = state;

      Map<String, dynamic> snapMap = (snapshot.value as Map<Object?, Object?>).cast<String, dynamic>();

      RobotInfo robotInfo = RobotInfo.fromMap(snapMap);
      final isHybrid = (currentState is RobotInfoSucess) ? (currentState).isHybrdidEnabled : robotInfo.status.isMowingHybrid;
      emit(
        RobotInfoSucess(
          robotInfo: robotInfo,
          isHybrdidEnabled: isHybrid,
        ),
      );
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
      } catch (e) {
        log(e.toString());
        emit(RobotInfoFail());
      }
    }
  }

  void statusSwitchUpdated(bool val) async {
    if (state is RobotInfoSucess) {
      final currentState = state as RobotInfoSucess;

      final newStatus = val ? (currentState.isHybrdidEnabled ? RobotStatus.mowingHybrid : RobotStatus.mowing) : RobotStatus.sleeping;

      final info = currentState.robotInfo.copyWith(
        startTime: val ? DateTime.now() : null,
        status: newStatus,
        atPoint: newStatus.isSleeping ? 0 : null,
      );

      await _firebaseRepository.setRobotInfo(info);

      emit(RobotInfoSucess(robotInfo: info, isHybrdidEnabled: currentState.isHybrdidEnabled));
    }
  }

  void hybrdiSwitchPress() async {
    if (state is RobotInfoSucess) {
      final currentState = state as RobotInfoSucess;
      emit(RobotInfoSucess(robotInfo: currentState.robotInfo, isHybrdidEnabled: !currentState.isHybrdidEnabled));
    }
  }

  void navigateHome() async {
    if (state is RobotInfoSucess) {
      final currentState = state as RobotInfoSucess;

      final info = currentState.robotInfo.copyWith(
        status: RobotStatus.navigatingHome,
      );

      await _firebaseRepository.setRobotInfo(info);
    }
  }

  @override
  Future<void> close() {
    _robotInfoSubscription?.cancel();
    return super.close();
  }
}
