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
            compassEnabled: true,
            mapType: MapType.satellite,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            onMapCreated: (controller) {
              _onMapCreated(controller);
              BlocProvider.of<CutAreaBloc>(context).add(CutAreaMapLoaded());
            },
            initialCameraPosition: CameraPosition(
              zoom: 18.0,
              target: state.homeBaseLocation ?? state.userLocation,
            ),
            markers: {
              ...state.markers.map(
                (e) {
                  return Marker(
                    visible: !state.showPoly,
                    markerId: MarkerId(e.id.toString()),
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
                  );
                },
              ).toSet(),
              Marker(
                markerId: const MarkerId("home-base-position"),
                position: state.homeBaseLocation!,
                visible: state.homeBaseLocation != null,
                draggable: false,
                icon: BitmapDescriptor.defaultMarkerWithHue(80),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId("path"),
                color: Colors.white,
                endCap: Cap.roundCap,
                width: 2,
                visible: state.showPath && state.isEnoughMarkers && state.path != null,
                points: state.path ?? [],
                startCap: Cap.roundCap,
              ),
              // Polyline(
              //   polylineId: const PolylineId("start-path"),
              //   color: Colors.blue,
              //   endCap: Cap.roundCap,
              //   visible: state.showPath && state.isEnoughMarkers && state.homeBaseLocation != null && state.path != null && state.path!.isNotEmpty,
              //   patterns: [
              //     PatternItem.dot,
              //     PatternItem.gap(5),
              //   ],
              //   width: 2,
              //   points: state.getMoveToStartPath(),
              //   startCap: Cap.roundCap,
              // ),
              // Polyline(
              //   polylineId: const PolylineId("end-path"),
              //   color: Colors.blue.shade200,
              //   endCap: Cap.roundCap,
              //   width: 2,
              //   visible: state.showPath && state.isEnoughMarkers && state.homeBaseLocation != null && state.path != null && state.path!.isNotEmpty,
              //   patterns: [
              //     PatternItem.dot,
              //     PatternItem.gap(5),
              //   ],
              //   points: state.getMoveHomePath(),
              //   startCap: Cap.roundCap,
              // ),
            },
            polygons: {
              Polygon(
                polygonId: const PolygonId("1"),
                fillColor: Colors.greenAccent.withOpacity(0.5),
                strokeColor: Colors.green,
                strokeWidth: 2,
                visible: state.showPoly && state.isEnoughMarkers,
                points: state.markers.map((e) => e.position).toList(),
              ),
            },
          );
        }

        return const LinearProgressIndicator();
      },
    );
  }
}
