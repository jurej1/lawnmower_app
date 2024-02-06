import 'dart:async';
import 'dart:developer' as dev;
import 'package:poly_repository/poly_repository.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

part 'cut_area_event.dart';
part 'cut_area_state.dart';

class CutAreaBloc extends Bloc<CutAreaEvent, CutAreaState> {
  CutAreaBloc({
    required LatLng userLocation,
    required FirebaseRepository firebaseRepository,
  })  : _firebaseRepository = firebaseRepository,
        super(
          CutAreaState(
            loadStatus: CutAreaStatus.initial,
            submitStatus: CutAreaStatus.initial,
            userLocation: userLocation,
            markers: [],
            showPoly: false,
            isMapLoaded: false,
            showPath: false,
          ),
        ) {
    on<CutAreaInit>(_mapInitToState);
    on<CutAreaOnDragEnd>(_mapDragAreaEndToState);
    on<CutAreaAddMarker>(_mapAddMarkerToState);
    on<CutAreaShowPoly>(_mapPolyToState);
    on<CutAreaRemoveMarker>(_mapRemoveMarkerToState);
    on<CutAreaSubmitPoly>(_maSubmitToState);
    on<CutAreaDeleteMarkers>(_mapDeleteMarkersToState);
    on<CutAreaMapLoaded>(_mapMapLoadedToState);
    on<CutAreaPathSwitchClicked>(_mapPathSwitchToState);
  }

  final FirebaseRepository _firebaseRepository;

  FutureOr<void> _mapDragAreaEndToState(CutAreaOnDragEnd event, Emitter<CutAreaState> emit) {
    var newList = List<MarkerShort>.from(state.markers);

    newList = newList.map((e) {
      if (e.id == event.id) {
        return MarkerShort(
          position: event.finalPosition,
          id: event.id,
        );
      }
      return e;
    }).toList();

    emit(state.copyWith(markers: newList));
  }

  FutureOr<void> _mapAddMarkerToState(CutAreaAddMarker event, Emitter<CutAreaState> emit) {
    var newList = List<MarkerShort>.from(state.markers);
    newList.add(MarkerShort(position: state.userLocation, id: MarkerId(newList.length.toString())));
    emit(state.copyWith(markers: newList));
  }

  FutureOr<void> _mapPolyToState(CutAreaShowPoly event, Emitter<CutAreaState> emit) {
    emit(state.copyWith(showPoly: !state.showPoly));
  }

  FutureOr<void> _mapRemoveMarkerToState(CutAreaRemoveMarker event, Emitter<CutAreaState> emit) {
    var newList = List<MarkerShort>.from(state.markers);
    newList.removeAt(newList.length - 1);
    emit(state.copyWith(markers: newList));
  }

  FutureOr<void> _maSubmitToState(CutAreaSubmitPoly event, Emitter<CutAreaState> emit) async {
    try {
      emit(state.copyWith(submitStatus: CutAreaStatus.loading));
      List<LatLng> points = state.markers.map((e) => e.position).toList();

      dev.log(points.toString());
      http.Response response = await _firebaseRepository.setCutArea(points);

      if (response.statusCode == 200) {
        emit(state.copyWith(submitStatus: CutAreaStatus.success));
      } else {
        emit(state.copyWith(submitStatus: CutAreaStatus.fail));
      }
    } catch (e) {
      emit(state.copyWith(submitStatus: CutAreaStatus.fail));
    }
  }

  FutureOr<void> _mapDeleteMarkersToState(CutAreaDeleteMarkers event, Emitter<CutAreaState> emit) {
    emit(state.copyWith(markers: []));
  }

  FutureOr<void> _mapInitToState(CutAreaInit event, Emitter<CutAreaState> emit) async {
    try {
      emit(state.copyWith(loadStatus: CutAreaStatus.loading));

      List<LatLng> points = await _firebaseRepository.getCutArea();

      LatLng robotLocation = await _firebaseRepository.getCurrentRobotLocation();

      List<MarkerShort> markers = points
          .map(
            (e) => MarkerShort(
              position: e,
              id: MarkerId(
                UniqueKey().toString(),
              ),
            ),
          )
          .toList();

      emit(
        state.copyWith(
          markers: markers,
          robotLocation: robotLocation,
          loadStatus: CutAreaStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadStatus: CutAreaStatus.fail,
        ),
      );
    }
  }

  FutureOr<void> _mapMapLoadedToState(CutAreaMapLoaded event, Emitter<CutAreaState> emit) {
    emit(state.copyWith(isMapLoaded: true));
  }

  FutureOr<void> _mapPathSwitchToState(CutAreaPathSwitchClicked event, Emitter<CutAreaState> emit) {
    emit(state.copyWith(showPath: !state.showPath));
  }
}
