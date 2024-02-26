import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lawnmower_app/home/blocs/blocs.dart';
import 'package:lawnmower_app/map/blocs/blocs.dart';
import 'package:lawnmower_app/map/widgets/widgets.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  static route(context, {required RobotInfoCubit robotInfoCubit}) {
    return MaterialPageRoute(
      builder: (_) {
        return BlocProvider.value(
          value: robotInfoCubit,
          child: const MapView(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocBuilder<UserLocationCubit, UserLocationState>(
        builder: (context, state) {
          if (state is UserLocationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is UserLocationFail) {
            return const Center(
              child: Text("Sorry there was an error when loading"),
            );
          }

          if (state is UserLocationLoaded) {
            final userLocation = LatLng(state.locationData.latitude!, state.locationData.longitude!);

            return _BodyBuilder.provider(userLocation);
          }

          return Container();
        },
      ),
    );
  }
}

class _BodyBuilder extends StatefulWidget {
  const _BodyBuilder({super.key});

  @override
  State<_BodyBuilder> createState() => _BodyBuilderState();

  static provider(LatLng userLocation) {
    return BlocProvider(
      create: (context) => CutAreaBloc(
        userLocation: userLocation,
        firebaseRepository: RepositoryProvider.of<FirebaseRepository>(context),
      )..add(CutAreaInit()),
      child: const _BodyBuilder(),
    );
  }
}

class _BodyBuilderState extends State<_BodyBuilder> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CutAreaBloc, CutAreaState>(
          listenWhen: (p, c) => p.submitStatus != c.submitStatus,
          listener: (context, state) {
            if (state.submitStatus == CutAreaStatus.success) {
              const snackbar = SnackBar(content: Text("Update Success"));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
              BlocProvider.of<RobotInfoCubit>(context).pathDataUpdated(
                pathLength: state.path?.length ?? 0,
                area: state.calculateAreaOfGPSPolygonOnEarthInSquareMeters(),
                duration: Duration(seconds: state.calculateMowingTimeInSeconds()),
              );
            } else if (state.submitStatus == CutAreaStatus.fail) {
              const snackbar = SnackBar(content: Text("Update Failed"));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            }
          },
        ),
        BlocListener<CutAreaBloc, CutAreaState>(
          listenWhen: (p, c) => p.loadStatus != c.loadStatus,
          listener: (context, state) {
            if (state.loadStatus == CutAreaStatus.success) {
              const snackbar = SnackBar(content: Text("Load Success"));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            } else if (state.loadStatus == CutAreaStatus.fail) {
              const snackbar = SnackBar(content: Text("Load Error"));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            }
          },
        ),
      ],
      child: const Stack(
        children: [
          GoogleMapDisplayer(),
          Positioned(
            top: 60,
            left: 20,
            child: TopActionRow(),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: BottomActionRow(),
          ),
        ],
      ),
    );
  }
}
