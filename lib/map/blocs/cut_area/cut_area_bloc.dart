import 'dart:async';
import 'dart:convert';
import 'package:poly_repository/poly_repository.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repository/firebase_repository.dart';
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
    on<CutAreaHomeBaseUpdated>(_mapHomeBaseUpdatedToState);
  }

  final FirebaseRepository _firebaseRepository;
  final double stepSize = 2;

  FutureOr<void> _mapDragAreaEndToState(CutAreaOnDragEnd event, Emitter<CutAreaState> emit) async {
    var newList = List<MarkerShort>.from(state.markers);

    newList = newList.map((e) {
      if (e.id == event.id) {
        return e.copyWith(
          position: event.finalPosition,
        );
      }
      return e;
    }).toList();

    final path = await generatePathInsidePolygon(
      newList
          .map(
            (e) => {
              "lat": e.position.latitude,
              "lng": e.position.longitude,
            },
          )
          .toList(),
      stepSize,
    );

    emit(
      state.copyWith(
        markers: newList,
        path: path,
      ),
    );
  }

  FutureOr<void> _mapAddMarkerToState(CutAreaAddMarker event, Emitter<CutAreaState> emit) async {
    var newList = List<MarkerShort>.from(state.markers);
    newList.add(MarkerShort(position: state.homeBaseLocation ?? state.userLocation, id: newList.length));

    final path = await generatePathInsidePolygon(
      newList
          .map(
            (e) => {
              "lat": e.position.latitude,
              "lng": e.position.longitude,
            },
          )
          .toList(),
      stepSize,
    );

    emit(
      state.copyWith(
        markers: newList,
        path: path,
      ),
    );
  }

  FutureOr<void> _mapPolyToState(CutAreaShowPoly event, Emitter<CutAreaState> emit) {
    emit(state.copyWith(showPoly: !state.showPoly));
  }

  FutureOr<void> _mapRemoveMarkerToState(CutAreaRemoveMarker event, Emitter<CutAreaState> emit) async {
    var newList = List<MarkerShort>.from(state.markers);
    newList.removeAt(newList.length - 1);
    final path = await generatePathInsidePolygon(
      newList
          .map(
            (e) => {
              "lat": e.position.latitude,
              "lng": e.position.longitude,
            },
          )
          .toList(),
      stepSize,
    );

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

      if (state.path != null) {
        final path = await generatePathInsidePolygon(
          points
              .map(
                (e) => {
                  "lat": e.latitude,
                  "lng": e.longitude,
                },
              )
              .toList(),
          stepSize,
        );

        emit(state.copyWith(path: path));
      }

      final cutArea = state.calculateAreaOfGPSPolygonOnEarthInSquareMeters();

      PathData pathData = PathData(
        cutArea: cutArea,
        duration: Duration(seconds: state.calculateMowingTimeInSeconds()),
        length: state.calculatePathLength(),
      );

      await Future.wait([
        _firebaseRepository.setPathData(pathData),
        _firebaseRepository.setCutPath(state.path!),
        _firebaseRepository.setCutArea(points),
      ]);

      // TODO Update other blocs once this is done.

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

      final path = await generatePathInsidePolygon(
        points
            .map(
              (e) => {
                "lat": e.latitude,
                "lng": e.longitude,
              },
            )
            .toList(),
        stepSize,
      );

      // lawnmower
      final lawnmowerSnapshot = await _firebaseRepository.getRobotLocation();
      Map<String, dynamic> valLawnMower = (lawnmowerSnapshot.value as Map<Object?, Object?>).cast<String, dynamic>();
      final LatLng lawnMower = LatLng(valLawnMower["lat"], valLawnMower["lng"]);

      emit(
        state.copyWith(
          markers: markers,
          homeBaseLocation: homebase,
          loadStatus: CutAreaStatus.success,
          path: path,
          mowerLocation: lawnMower,
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

  Future<List<LatLng>?> generatePathInsidePolygon(List<Map<String, double>> points, double stepSize) async {
    // Define the URL of the server function
    const String url = 'https://us-central1-lawnmower-825c3.cloudfunctions.net/generatePathInsidePolygon';

    // Construct the request body
    final Map<String, dynamic> requestBody = {
      'polygonPoints': points,
      'stepM': stepSize,
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // Parse the response data
        final responseData = json.decode(response.body);
        // Use the responseData for your path
        print('Response data: $responseData');

        List<LatLng> path = (responseData as List<dynamic>)
            .map<LatLng>(
              (e) => LatLng(
                e["latitude"] ?? 0.0000,
                e["longitude"] ?? 0.0000,
              ),
            )
            .toList();
        print('Response data PATH: $path');
        return path;
      } else {
        // Handle the case where the server returns a non-200 status code
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print('Error making the request: $e');
    }
    return null;
  }

  FutureOr<void> _mapHomeBaseUpdatedToState(CutAreaHomeBaseUpdated event, Emitter<CutAreaState> emit) async {
    final newState = state.copyWith(homeBaseLocation: event.finalPosition);

    await _firebaseRepository.setHomebaseGPS(event.finalPosition);

    emit(newState);
  }
}
