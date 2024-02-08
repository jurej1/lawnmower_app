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
          return Column(
            children: [
              Text(
                mapStatusToText(state.workData.status),
                style: TextStyle(
                  color: mapStatusToColor(state.workData.status),
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(12),
              //   child: Container(
              //     height: 5,
              //     width: 180,
              //     decoration: BoxDecoration(
              //       color: Colors.grey.shade800,
              //     ),
              //     child: const FractionallySizedBox(
              //       alignment: Alignment.centerLeft,
              //       heightFactor: 1,
              //       widthFactor: 0.4,
              //       child: ColoredBox(color: Colors.green),
              //     ),
              //   ),
              // ),

              // TODO: fix this thing
              // if charging -> display charging animation
              // if sleeping -> animate bed or someting.
              // if mowing -> animate how much it still has.
            ],
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
    } else {
      return "Sleeping";
    }
  }

  Color mapStatusToColor(RobotStatus status) {
    if (status.isCharging) {
      return Colors.blue;
    } else if (status.isMowing) {
      return Colors.green;
    } else {
      return Colors.purple.shade100;
    }
  }
}
