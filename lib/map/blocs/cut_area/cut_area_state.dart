// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'cut_area_bloc.dart';

class MarkerShort extends Equatable {
  final LatLng position;
  final MarkerId id;

  const MarkerShort({
    required this.position,
    required this.id,
  });

  @override
  List<Object> get props => [position, id];

  MarkerShort copyWith({
    LatLng? position,
    MarkerId? id,
  }) {
    return MarkerShort(
      position: position ?? this.position,
      id: id ?? this.id,
    );
  }
}

enum CutAreaStatus {
  initial,
  loading,
  success,
  fail,
}

class CutAreaState {
  const CutAreaState({
    required this.markers,
    required this.userLocation,
    this.robotLocation,
    required this.showPoly,
    required this.submitStatus,
    required this.loadStatus,
    required this.isMapLoaded,
    required this.showPath,
  });

  final List<MarkerShort> markers;
  final LatLng userLocation;
  final LatLng? robotLocation;
  final bool showPoly;
  final bool showPath;

  final CutAreaStatus submitStatus;
  final CutAreaStatus loadStatus;
  final bool isMapLoaded;

  CutAreaState copyWith({
    List<MarkerShort>? markers,
    LatLng? userLocation,
    LatLng? robotLocation,
    bool? showPoly,
    bool? showPath,
    CutAreaStatus? submitStatus,
    CutAreaStatus? loadStatus,
    bool? isMapLoaded,
  }) {
    return CutAreaState(
      markers: markers ?? this.markers,
      userLocation: userLocation ?? this.userLocation,
      robotLocation: robotLocation ?? this.robotLocation,
      showPoly: showPoly ?? this.showPoly,
      showPath: showPath ?? this.showPath,
      submitStatus: submitStatus ?? this.submitStatus,
      loadStatus: loadStatus ?? this.loadStatus,
      isMapLoaded: isMapLoaded ?? this.isMapLoaded,
    );
  }

  bool get isEnoughMarkers => markers.length > 2;

  final PolyRepository _polyRepository = const PolyRepository();

  double calculateAreaOfGPSPolygonOnEarthInSquareMeters() {
    return _polyRepository.calculateAreaOfGPSPolygonOnEarthInSquareMeters(markers.map((e) => e.position).toList());
  }

  double calculateMowingTime() {
    return _polyRepository.calculateMowingTime(pathLength: calculatePathLength());
  }

  List<LatLng> generatePathInsidePolygon({double stepM = 2}) {
    final points = List<LatLng>.from(markers.map((e) => e.position).toList());
    return _polyRepository.generatePathInsidePolygon(points, stepM);
  }

  double calculatePathLength() {
    return _polyRepository.calculatePathLength(generatePathInsidePolygon());
  }
}
