part of 'cut_area_bloc.dart';

sealed class CutAreaEvent extends Equatable {
  const CutAreaEvent();

  @override
  List<Object> get props => [];
}

class CutAreaAddMarker extends CutAreaEvent {}

class CutAreaInit extends CutAreaEvent {}

class CutAreaRemoveMarker extends CutAreaEvent {}

class CutAreaOnDragEnd extends CutAreaEvent {
  final LatLng finalPosition;
  final MarkerId id;

  const CutAreaOnDragEnd({required this.finalPosition, required this.id});
}

class CutAreaShowPoly extends CutAreaEvent {}

class CutAreaSubmitPoly extends CutAreaEvent {}

class CutAreaDeleteMarkers extends CutAreaEvent {}

class CutAreaMapLoaded extends CutAreaEvent {}

class CutAreaPathSwitchClicked extends CutAreaEvent {}
