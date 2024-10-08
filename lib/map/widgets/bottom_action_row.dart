import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/map/blocs/cut_area/cut_area_bloc.dart';

class BottomActionRow extends StatelessWidget {
  const BottomActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CutAreaBloc, CutAreaState>(
      builder: (context, state) {
        return Row(
          children: [
            if (state.isMapLoaded && state.isEnoughMarkers)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "A: ${state.calculateAreaOfGPSPolygonOnEarthInSquareMeters().round()} m²",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "t: ${(state.calculateMowingTimeInSeconds() / 60).round()} min",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "l: ${state.calculatePathLength().round()} m",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            const SizedBox(width: 10),
            if (state.isMapLoaded && state.isEnoughMarkers)
              CupertinoSwitch(
                activeColor: Colors.green,
                trackColor: Colors.green.withOpacity(0.2),
                onChanged: (val) {
                  BlocProvider.of<CutAreaBloc>(context).add(CutAreaShowPoly());
                },
                value: state.showPoly,
              ),
            const SizedBox(width: 10),
            if (state.isMapLoaded && state.isEnoughMarkers)
              CupertinoSwitch(
                trackColor: Colors.blue.withOpacity(0.4),
                activeColor: Colors.blue,
                onChanged: (val) {
                  BlocProvider.of<CutAreaBloc>(context).add(CutAreaPathSwitchClicked());
                },
                value: state.showPath,
              ),
          ],
        );
      },
    );
  }
}
