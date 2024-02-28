import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/home/blocs/robot_info/robot_info_cubit.dart';

class StatusTextDisplayer extends StatelessWidget {
  const StatusTextDisplayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotInfoCubit, RobotInfoState>(
      builder: (context, state) {
        if (state is RobotInfoLoading) return const CircularProgressIndicator();

        if (state is RobotInfoSucess) {
          return Text(
            mapStatusToText(state.robotInfo.status),
            style: TextStyle(
              color: mapStatusToColor(state.robotInfo.status),
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          );
        }

        return const Text("Error");
      },
    );
  }

  String mapStatusToText(RobotStatus status) {
    if (status.isCharging) {
      return "Charging";
    } else if (status.isMowing) {
      return "Mowing";
    } else if (status.isSleeping) {
      return "Sleeping";
    } else if (status.isNavigating) {
      return "Navigating...";
    } else if (status.isNavigatingHome) {
      return "Navigating home";
    } else if (status.isMowingHybrid) {
      return "Mowing Hybrid";
    } else {
      return "...";
    }
  }

  Color mapStatusToColor(RobotStatus status) {
    if (status.isCharging) {
      return Colors.blue;
    } else if (status.isMowing) {
      return Colors.green;
    } else if (status.isCharging) {
      return Colors.purple.shade100;
    } else {
      return Colors.green;
    }
  }
}
