import 'dart:async';
import 'package:poly_repository/poly_repository.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  final double stepSize = 3;

  FutureOr<void> _mapDragAreaEndToState(CutAreaOnDragEnd event, Emitter<CutAreaState> emit) {
    var newList = List<MarkerShort>.from(state.markers);

    newList = newList.map((e) {
      if (e.id == event.id) {
        return e.copyWith(
          position: event.finalPosition,
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
    newList.add(MarkerShort(position: state.homeBaseLocation ?? state.userLocation, id: newList.length));
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

      await _firebaseRepository.setCutArea(points);

      if (state.path != null) {
        List<LatLng> path = _polyRepository.generatePathInsidePolygon(points, stepSize);
        emit(state.copyWith(path: path));
      }

      await _firebaseRepository.setCutPath(state.path!);

      PathData pathData = PathData(
        cutArea: state.calculateAreaOfGPSPolygonOnEarthInSquareMeters(),
        duration: Duration(seconds: state.calculateMowingTime()),
        length: state.calculatePathLength(),
      );

      await _firebaseRepository.setPathData(pathData);

      emit(state.copyWith(submitStatus: CutAreaStatus.success));
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

      // points
      final cutAreaSnapshot = await _firebaseRepository.getCutArea();
      List<LatLng> points = (cutAreaSnapshot.value as List<dynamic>).map<LatLng>((e) => LatLng(e["lat"], e["lng"])).toList();

      List<MarkerShort> markers = points
          .asMap()
          .map<int, MarkerShort>(
            (key, value) => MapEntry(
              key,
              MarkerShort(id: key, position: value),
            ),
          )
          .values
          .toList();

      //homebase
      final homebaseSnapshot = await _firebaseRepository.getHomeBaseGPS();
      Map<String, dynamic> valHomeBase = (homebaseSnapshot.value as Map<Object?, Object?>).cast<String, dynamic>();
      final LatLng homebase = LatLng(valHomeBase["lat"], valHomeBase["lng"]);

      // List<LatLng> path = await _firebaseRepository.getCutPath();

      // List<MarkerShort> markers = points.asMap()
      //     .map(
      //       (e) => MarkerShort(
      //         position: e,
      //         id: MarkerId(
      //           UniqueKey().toString(),
      //         ),
      //       ),
      //     )
      //     .toList();

      final path = _polyRepository.generatePathInsidePolygon(points, stepSize);
      emit(
        state.copyWith(
          markers: markers,
          homeBaseLocation: homebase,
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
