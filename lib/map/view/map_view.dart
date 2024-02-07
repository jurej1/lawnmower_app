import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lawnmower_app/map/blocs/blocs.dart';
import 'package:lawnmower_app/map/widgets/widgets.dart';
import 'dart:developer';

import 'package:poly_repository/poly_repository.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  static route(context) {
    return MaterialPageRoute(
      builder: (_) {
        return const MapView();
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
  _BodyBuilder({super.key});

  @override
  State<_BodyBuilder> createState() => _BodyBuilderState();

  static provider(LatLng userLocation) {
    return BlocProvider(
      create: (context) => CutAreaBloc(
        userLocation: userLocation,
        firebaseRepository: RepositoryProvider.of<FirebaseRepository>(context),
        polyRepository: RepositoryProvider.of<PolyRepository>(context),
      )..add(CutAreaInit()),
      child: _BodyBuilder(),
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
      child: BlocBuilder<CutAreaBloc, CutAreaState>(
        builder: (context, state) {
          return Stack(
            children: [
              GoogleMapDisplayer(),
              const Positioned(
                top: 60,
                left: 20,
                child: TopActionRow(),
              ),
              const Positioned(
                bottom: 30,
                left: 20,
                child: BottomActionRow(),
              ),
            ],
          );
        },
      ),
    );
  }
}
