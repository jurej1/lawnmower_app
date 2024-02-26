// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'cut_area_bloc.dart';

class MarkerShort extends Equatable {
  final LatLng position;
  final int id;

  const MarkerShort({
    required this.position,
    required this.id,
  });

  @override
  List<Object> get props => [position, id];

  MarkerShort copyWith({
    LatLng? position,
    int? id,
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

class CutAreaState extends Equatable {
  const CutAreaState({
    required this.markers,
    this.path,
    required this.userLocation,
    this.homeBaseLocation,
    required this.showPoly,
    required this.showPath,
    required this.submitStatus,
    required this.loadStatus,
    required this.isMapLoaded,
    required this.areaOfGPSPolygon,
  });

  final List<MarkerShort> markers;
  final List<LatLng>? path;
  final LatLng userLocation;
  final LatLng? homeBaseLocation;
  final bool showPoly;
  final bool showPath;
  final CutAreaStatus submitStatus;
  final CutAreaStatus loadStatus;
  final bool isMapLoaded;
  final double areaOfGPSPolygon;

  CutAreaState copyWith({
    List<MarkerShort>? markers,
    List<LatLng>? path,
    LatLng? userLocation,
    LatLng? homeBaseLocation,
    bool? showPoly,
    bool? showPath,
    CutAreaStatus? submitStatus,
    CutAreaStatus? loadStatus,
    bool? isMapLoaded,
    double? areaOfGPSPolygon,
  }) {
    return CutAreaState(
      markers: markers ?? this.markers,
      path: path ?? this.path,
      userLocation: userLocation ?? this.userLocation,
      homeBaseLocation: homeBaseLocation ?? this.homeBaseLocation,
      showPoly: showPoly ?? this.showPoly,
      showPath: showPath ?? this.showPath,
      submitStatus: submitStatus ?? this.submitStatus,
      loadStatus: loadStatus ?? this.loadStatus,
      isMapLoaded: isMapLoaded ?? this.isMapLoaded,
      areaOfGPSPolygon: areaOfGPSPolygon ?? this.areaOfGPSPolygon,
    );
  }

  bool get isEnoughMarkers => markers.length > 2;

  final PolyRepository _polyRepository = const PolyRepository();

  int calculateMowingTimeInSeconds() {
    return _polyRepository.calculateMowingTimeInSeconds(pathLength: calculatePathLength());
  }

  double calculatePathLength() {
    return _polyRepository.calculatePathLength(path ?? []);
  }

  List<LatLng> getMoveToStartPath() {
    if (homeBaseLocation == null && path == null || path!.isEmpty) return [];
    return [homeBaseLocation!, path!.first];
  }

  List<LatLng> getMoveHomePath() {
    if (path == null && homeBaseLocation == null || path!.isEmpty) return [];
    return [path!.last, homeBaseLocation!];
  }

  @override
  List<Object?> get props {
    return [
      markers,
      path,
      userLocation,
      homeBaseLocation,
      showPoly,
      showPath,
      submitStatus,
      loadStatus,
      isMapLoaded,
      areaOfGPSPolygon,
    ];
  }
}
