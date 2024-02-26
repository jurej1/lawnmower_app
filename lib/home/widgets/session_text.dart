import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lawnmower_app/home/blocs/blocs.dart';

class SessionText extends StatelessWidget {
  const SessionText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotInfoCubit, RobotInfoState>(
      builder: (context, state) {
        if (state is RobotInfoSucess) {
          if (state.robotInfo.status.isCharging) {
            return Container();
          } else if (state.robotInfo.status.isMowing) {
            if (state.robotInfo.estimatedEndTime == null) return Container();
            return Text("Mowing session ends at ${DateFormat("HH:mm").format(state.robotInfo.estimatedEndTime!)}");
          } else if (state.robotInfo.status.isSleeping) {
            if (state.robotInfo.estimatedEndTime == null) return Container();
            return Text("If Start Now mowing would end at ${DateFormat("HH:mm").format(state.robotInfo.estimatedEndTime!)}");
          }
        }
        return Container();
      },
    );
  }
}
