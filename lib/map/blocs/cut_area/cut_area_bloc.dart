import 'dart:async';
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
    required PolyRepository polyRepository,
  })  : _firebaseRepository = firebaseRepository,
        _polyRepository = polyRepository,
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
  final PolyRepository _polyRepository;
  final double stepSize = 5;

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

    final path = _polyRepository.generatePathInsidePolygon(newList.map((e) => e.position).toList(), stepSize);

    emit(
      state.copyWith(
        markers: newList,
        path: path,
      ),
    );
  }

  FutureOr<void> _mapAddMarkerToState(CutAreaAddMarker event, Emitter<CutAreaState> emit) {
    var newList = List<MarkerShort>.from(state.markers);
    newList.add(MarkerShort(position: state.userLocation, id: MarkerId(newList.length.toString())));
    final path = _polyRepository.generatePathInsidePolygon(newList.map((e) => e.position).toList(), stepSize);

    emit(state.copyWith(markers: newList, path: path));
  }

  FutureOr<void> _mapPolyToState(CutAreaShowPoly event, Emitter<CutAreaState> emit) {
    emit(state.copyWith(showPoly: !state.showPoly));
  }

  FutureOr<void> _mapRemoveMarkerToState(CutAreaRemoveMarker event, Emitter<CutAreaState> emit) {
    var newList = List<MarkerShort>.from(state.markers);
    newList.removeAt(newList.length - 1);
    final path = _polyRepository.generatePathInsidePolygon(newList.map((e) => e.position).toList(), stepSize);

    emit(
      state.copyWith(
        markers: newList,
        path: path,
      ),
    );
  }

  FutureOr<void> _maSubmitToState(CutAreaSubmitPoly event, Emitter<CutAreaState> emit) async {
    try {
      emit(state.copyWith(submitStatus: CutAreaStatus.loading));
      List<LatLng> points = state.markers.map((e) => e.position).toList();

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

  FutureOr<void> _mapDeleteMarkersToState(CutAreaDeleteMarkers event, Emitter<CutAreaState> emit) async {
    try {
      // await _firebaseRepository.setCutArea([]);
      emit(
        state.copyWith(
          markers: [],
          path: [],
        ),
      );
    } catch (e) {
      emit(state);
    }
  }

  FutureOr<void> _mapInitToState(CutAreaInit event, Emitter<CutAreaState> emit) async {
    try {
      emit(state.copyWith(loadStatus: CutAreaStatus.loading));

      List<LatLng> points = await _firebaseRepository.getCutArea();

      LatLng homeBaseLocation = await _firebaseRepository.getHomeBaseGPS();

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

      final path = _polyRepository.generatePathInsidePolygon(points, stepSize);
      emit(
        state.copyWith(
          markers: markers,
          homeBaseLocation: homeBaseLocation,
          loadStatus: CutAreaStatus.success,
          path: path,
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
    final newShowPath = !state.showPath;
    emit(
      state.copyWith(
        showPath: newShowPath,
        showPoly: newShowPath == true ? true : null,
      ),
    );
  }
}
