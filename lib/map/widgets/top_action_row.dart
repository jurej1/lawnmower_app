import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/map/blocs/cut_area/cut_area_bloc.dart';

class TopActionRow extends StatelessWidget {
  const TopActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CutAreaBloc, CutAreaState>(
      builder: (context, state) {
        return Wrap(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.add),
                onPressed: () {
                  BlocProvider.of<CutAreaBloc>(context).add(CutAreaAddMarker());
                },
              ),
            ),
            const SizedBox(width: 15),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.remove),
                onPressed: state.markers.length > 1
                    ? () {
                        BlocProvider.of<CutAreaBloc>(context).add(CutAreaRemoveMarker());
                      }
                    : null,
              ),
            ),
            const SizedBox(width: 15),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.check),
                onPressed: () {
                  BlocProvider.of<CutAreaBloc>(context).add(CutAreaSubmitPoly());
                },
              ),
            ),
            const SizedBox(width: 15),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  BlocProvider.of<CutAreaBloc>(context).add(CutAreaDeleteMarkers());
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
