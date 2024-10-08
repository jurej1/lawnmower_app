import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/cut_area/cut_area_bloc.dart';

class GoogleMapDisplayer extends StatefulWidget {
  const GoogleMapDisplayer({super.key});

  @override
  State<GoogleMapDisplayer> createState() => _GoogleMapDisplayerState();
}

class _GoogleMapDisplayerState extends State<GoogleMapDisplayer> {
  final Completer<GoogleMapController> _controller = Completer();

  BitmapDescriptor homeBaseIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor lawnmowerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor pathIcon = BitmapDescriptor.defaultMarker;

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    BlocProvider.of<CutAreaBloc>(context).add(CutAreaMapLoaded());
  }

  void setCustomMarkerIcon() async {
    await Future.wait([
      getBytesFromAsset("assets/home_base.png", 50).then((value) {
        homeBaseIcon = BitmapDescriptor.fromBytes(value);
      }),
      getBytesFromAsset("assets/path_point.png", 50).then((value) {
        pathIcon = BitmapDescriptor.fromBytes(value);
      }),
      getBytesFromAsset("assets/mower_point.png", 50).then((value) {
        lawnmowerIcon = BitmapDescriptor.fromBytes(value);
      }),
    ]);
  }

  @override
  void initState() {
    super.initState();
    setCustomMarkerIcon();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CutAreaBloc, CutAreaState>(
      builder: (context, state) {
        if (state.loadStatus == CutAreaStatus.success) {
          return GoogleMap(
            mapType: MapType.satellite,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              zoom: 18.5,
              target: state.homeBaseLocation ?? state.userLocation,
            ),
            markers: {
              if (!state.showPoly)
                ...state.markers.map(
                  (e) {
                    return Marker(
                      markerId: MarkerId(e.id.toString()),
                      icon: pathIcon,
                      position: e.position,
                      anchor: const Offset(0.5, 0.5),
                      draggable: true,
                      flat: true,
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
                draggable: true,
                onDragEnd: (val) {
                  BlocProvider.of<CutAreaBloc>(context).add(CutAreaHomeBaseUpdated(finalPosition: val));
                },
                icon: homeBaseIcon,
              ),
              Marker(
                markerId: const MarkerId("lawnmower-position"),
                position: state.mowerLocation!,
                visible: state.mowerLocation != null,
                draggable: false,
                icon: lawnmowerIcon,
              ),
            },
            polylines: {
              if (state.showPath && state.isEnoughMarkers && state.path != null)
                Polyline(
                  polylineId: const PolylineId("path"),
                  color: Colors.white,
                  endCap: Cap.roundCap,
                  width: 2,
                  points: state.path ?? [],
                  startCap: Cap.roundCap,
                ),
              if (state.showPath && state.isEnoughMarkers && state.homeBaseLocation != null && state.path != null && state.path!.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId("start-path"),
                  color: Colors.blue,
                  endCap: Cap.roundCap,
                  patterns: [
                    PatternItem.dot,
                    PatternItem.gap(5),
                  ],
                  width: 2,
                  points: state.getMoveToStartPath(),
                  startCap: Cap.roundCap,
                ),
              if (state.showPath && state.isEnoughMarkers && state.homeBaseLocation != null && state.path != null && state.path!.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId("end-path"),
                  color: Colors.blue.shade200,
                  endCap: Cap.roundCap,
                  width: 2,
                  patterns: [
                    PatternItem.dot,
                    PatternItem.gap(5),
                  ],
                  points: state.getMoveHomePath(),
                  startCap: Cap.roundCap,
                ),
            },
            polygons: {
              if (state.showPoly && state.isEnoughMarkers)
                Polygon(
                  polygonId: const PolygonId("1"),
                  fillColor: Colors.greenAccent.withOpacity(0.5),
                  strokeColor: Colors.green,
                  strokeWidth: 2,
                  points: state.markers.map((e) => e.position).toList(),
                ),
            },
          );
        }

        return const LinearProgressIndicator();
      },
    );
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
}
