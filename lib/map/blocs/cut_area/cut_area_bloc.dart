import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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
            areaOfGPSPolygon: 0.0,
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
  final double stepSize = 2;
  static const double EARTH_RADIUS = 6371000;

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

    final areaCalculated = await calculateAreaOfGPSPolygonOnSphereInSquareMeters(path ?? [], EARTH_RADIUS);

    emit(
      state.copyWith(
        markers: newList,
        path: path,
        areaOfGPSPolygon: areaCalculated,
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
    final areaCalculated = await calculateAreaOfGPSPolygonOnSphereInSquareMeters(path ?? [], EARTH_RADIUS);

    emit(
      state.copyWith(
        markers: newList,
        path: path,
        areaOfGPSPolygon: areaCalculated,
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
    final areaCalculated = await calculateAreaOfGPSPolygonOnSphereInSquareMeters(path ?? [], EARTH_RADIUS);

    emit(
      state.copyWith(
        markers: newList,
        path: path,
        areaOfGPSPolygon: areaCalculated,
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

      final areaCalculated = await calculateAreaOfGPSPolygonOnSphereInSquareMeters(state.path ?? [], EARTH_RADIUS);

      PathData pathData = PathData(
        cutArea: areaCalculated,
        duration: Duration(seconds: state.calculateMowingTimeInSeconds()),
        length: state.calculatePathLength(),
      );

      // final path = await generatePathInsidePolygon(
      //     points
      //         .map(
      //           (e) => {
      //             "lat": e.latitude,
      //             "lng": e.longitude,
      //           },
      //         )
      //         .toList(),
      //     0.3);

      await Future.wait([
        _firebaseRepository.setPathData(pathData),
        _firebaseRepository.setCutPath(state.path!),
        _firebaseRepository.setMowingDurationAndArea(
          Duration(seconds: state.calculateMowingTimeInSeconds()),
          state.areaOfGPSPolygon,
        ),
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
          areaOfGPSPolygon: 0.0,
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

      final areaCalculated = await calculateAreaOfGPSPolygonOnSphereInSquareMeters(path ?? [], EARTH_RADIUS);

      emit(
        state.copyWith(
          markers: markers,
          homeBaseLocation: homebase,
          loadStatus: CutAreaStatus.success,
          path: path,
          areaOfGPSPolygon: areaCalculated,
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

  Future<double> calculateAreaOfGPSPolygonOnSphereInSquareMeters(List<LatLng> locations, double radius) async {
    if (locations.isEmpty) return 0.0;
    // Replace with the URL of your deployed Firebase Cloud Function
    final url = Uri.parse('https://us-central1-lawnmower-825c3.cloudfunctions.net/calculateAreaOfGPSPolygon');

    // Prepare the locations data
    final locationData = locations.map((location) => {'latitude': location.latitude, 'longitude': location.longitude}).toList();

    // Make the POST request
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'locations': locationData, 'radius': radius}),
    );

    // Check the response status
    if (response.statusCode == 200) {
      // Parse the response body
      final responseData = json.decode(response.body);
      log("data: ${responseData['area']}");
      return responseData['area'];
    } else {
      // Handle the error; throw an exception or return a default value
      throw Exception('Failed to calculate area: ${response.body}');
    }
  }
}
