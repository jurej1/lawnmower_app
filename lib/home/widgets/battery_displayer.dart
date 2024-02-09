import 'package:based_battery_indicator/based_battery_indicator.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/home/blocs/blocs.dart';

class BatteryDisplayer extends StatelessWidget {
  const BatteryDisplayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotInfoCubit, RobotInfoState>(
      builder: (context, state) {
        if (state is RobotInfoSucess) {
          return BasedBatteryIndicator(
            status: BasedBatteryStatus(
              value: state.robotInfo.batteryState,
              type: state.robotInfo.status.isCharging ? BasedBatteryStatusType.charging : BasedBatteryStatusType.normal,
            ),
            trackHeight: 20.0,
            trackAspectRatio: 2.0,
            curve: Curves.ease,
            // duration: const Duration(second: 1),
          );
        } else if (state is RobotInfoLoading) {
          return const CircularProgressIndicator();
        } else {
          return Container();
        }
      },
    );
  }
}
