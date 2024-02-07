import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lawnmower_app/map/blocs/blocs.dart';
import 'package:poly_repository/poly_repository.dart';

part 'robot_path_event.dart';
part 'robot_path_state.dart';

class RobotPathBloc extends Bloc<RobotPathEvent, RobotPathState> {
  RobotPathBloc({
    required PolyRepository firebaseRepository,
  })  : _polyReposittory = firebaseRepository,
        super(RobotPathLoading()) {
    on<RobotPathMarkersUpdated>(_mapMarkersUpdatedToState);
  }

  final PolyRepository _polyReposittory;

  FutureOr<void> _mapMarkersUpdatedToState(RobotPathMarkersUpdated event, Emitter<RobotPathState> emit) async {}
}
