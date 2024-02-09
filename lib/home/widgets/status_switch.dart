import 'package:blur/blur.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/home/blocs/blocs.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class StatusSwitch extends StatelessWidget {
  const StatusSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotInfoCubit, RobotInfoState>(
      builder: (context, state) {
        if (state is RobotInfoLoading) return const CircularProgressIndicator();
        if (state is RobotInfoSucess) {
          if (state.robotInfo.status.isCharging) {
            return Blur(
              blur: 7,
              blurColor: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(6),
              overlay: const Text("Let me charg nigga..."),
              child: IgnorePointer(
                child: _switch(info: state.robotInfo, context: context),
              ),
            );
          } else {
            return _switch(
              info: state.robotInfo,
              context: context,
            );
          }
        }
        return Container();
      },
    );
  }

  Widget _switch({
    required RobotInfo info,
    required BuildContext context,
  }) {
    return LiteRollingSwitch(
      width: 200,
      value: info.status.isMowing ? true : false,
      textOn: 'eating grass',
      textOff: 'on vacation...',
      colorOn: Colors.green,
      colorOff: Colors.redAccent.shade700,
      iconOn: Icons.check,
      iconOff: Icons.beach_access,
      // textSize: 16.0,
      textOnColor: Colors.white,
      onChanged: (bool state) {
        BlocProvider.of<RobotInfoCubit>(context).statusSwitchUpdated(state);
      },
      onTap: () {},
      onDoubleTap: () {},
      onSwipe: () {},
    );
  }
}
