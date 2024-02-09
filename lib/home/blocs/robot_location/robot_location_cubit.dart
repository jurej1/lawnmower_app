import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'robot_location_state.dart';

class RobotLocationCubit extends Cubit<RobotLocationState> {
  RobotLocationCubit({
    required FirebaseRepository firebaseRepository,
  })  : _firebaseRepository = firebaseRepository,
        super(RobotLocationLoading());

  final FirebaseRepository _firebaseRepository;

  Future<void> loadData() async {
    try {
      DataSnapshot homeBaseSnapshot = await _firebaseRepository.getHomeBaseGPS();
      DataSnapshot currentSnapshot = await _firebaseRepository.getRobotLocation();

      Map<String, dynamic> homeMap = (homeBaseSnapshot.value as Map<Object?, Object?>).cast<String, dynamic>();
      Map<String, dynamic> currentMap = (currentSnapshot.value as Map<Object?, Object?>).cast<String, dynamic>();

      LatLng home = LatLng(
        homeMap["lat"],
        homeMap["lng"],
      );

      LatLng current = LatLng(
        currentMap["lat"],
        currentMap["lng"],
      );

      emit(RobotLocationSuccess(robotLocation: current, homeBase: home));
    } catch (e) {
      emit(RobotLocationFail());
    }
  }
}
