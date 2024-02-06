import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/cut_area/cut_area_bloc.dart';

class GoogleMapDisplayer extends StatelessWidget {
  GoogleMapDisplayer({super.key});

  final Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CutAreaBloc, CutAreaState>(
      builder: (context, state) {
        if (state.loadStatus == CutAreaStatus.success) {
          return GoogleMap(
            buildingsEnabled: true,
            compassEnabled: true,
            mapType: MapType.satellite,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onMapCreated: (controller) {
              _onMapCreated(controller);
              BlocProvider.of<CutAreaBloc>(context).add(CutAreaMapLoaded());
            },
            initialCameraPosition: CameraPosition(
              zoom: 18.0,
              target: state.userLocation,
            ),
            markers: {
              ...state.markers
                  .map(
                    (e) => Marker(
                      infoWindow: InfoWindow(
                        title: e.id.value.toString(),
                      ),
                      visible: !state.showPoly,
                      markerId: e.id,
                      position: e.position,
                      draggable: true,
                      onDragEnd: (val) {
                        BlocProvider.of<CutAreaBloc>(context).add(
                          CutAreaOnDragEnd(
                            finalPosition: val,
                            id: e.id,
                          ),
                        );
                      },
                    ),
                  )
                  .toSet()
            },
            polylines: state.showPath && state.isEnoughMarkers
                ? {
                    Polyline(
                      polylineId: const PolylineId("path"),
                      color: Colors.white,
                      endCap: Cap.roundCap,
                      width: 2,
                      points: state.generatePathInsidePolygon(),
                      startCap: Cap.roundCap,
                    ),
                  }
                : {},
            polygons: state.showPoly && state.isEnoughMarkers
                ? {
                    Polygon(
                      polygonId: const PolygonId("1"),
                      fillColor: Colors.greenAccent.withOpacity(0.5),
                      strokeColor: Colors.green,
                      strokeWidth: 2,
                      visible: state.showPoly,
                      points: state.markers.map((e) => e.position).toList(),
                    ),
                  }
                : {},
          );
        }

        return const LinearProgressIndicator();
      },
    );
  }
}
