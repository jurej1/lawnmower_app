import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:lawnmower_app/bluetooth/blocs/blue_control/blue_control_bloc.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class ControlDeviceView extends StatefulWidget {
  const ControlDeviceView({
    super.key,
  });

  static route(BluetoothDevice device) {
    return MaterialPageRoute(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => BlueControlBloc(device)..add(const BlueControlInit())),
          ],
          child: const ControlDeviceView(),
        );
      },
    );
  }

  @override
  State<ControlDeviceView> createState() => _ControlDeviceViewState();
}

class _ControlDeviceViewState extends State<ControlDeviceView> {
  @override
  void initState() {
    super.initState();

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    // ]);
  }

  @override
  void dispose() {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BlueControlBloc, BlueControlState>(
      // listenWhen: (prev, current) {
      // },
      listener: (c, state) {
        if (state.hasNotificationBeenShown == false) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          final snackbar = SnackBar(
            content: Text(state.notificationMessage),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);

          BlocProvider.of<BlueControlBloc>(context).add(const BlueControlNotificationDisplayUpdated(val: true));
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<BlueControlBloc, BlueControlState>(
          builder: (context, state) {
            if (state.status == BlueConnectionStatus.connected) {
              return const Stack(
                children: [
                  _CuttingSpeed(),
                  _Joystick(),
                ],
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class _CuttingSpeed extends StatefulWidget {
  const _CuttingSpeed();

  @override
  State<_CuttingSpeed> createState() => _CuttingSpeedState();
}

class _CuttingSpeedState extends State<_CuttingSpeed> {
  double _val = 0.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlueControlBloc, BlueControlState>(
      builder: (context, state) {
        return Positioned(
          left: 0,
          bottom: 200,
          top: 50,
          child: SfSlider.vertical(
            min: 0.0,
            max: 100.0,
            value: _val,
            shouldAlwaysShowTooltip: true,
            tooltipPosition: SliderTooltipPosition.right,
            stepSize: 10.0,
            onChangeEnd: (val) {
              BlocProvider.of<BlueControlBloc>(context).add(BlueControlSetCuttingSpeed(speed: val));
            },
            onChanged: (val) {
              setState(() {
                _val = val;
              });
            },
          ),
        );
      },
    );
  }
}

class _Joystick extends StatelessWidget {
  const _Joystick();

  // CHANGE JOYSTICK TO SOMETHING ELSE.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlueControlBloc, BlueControlState>(
      builder: (context, state) {
        return Align(
          alignment: const Alignment(0, 0.8),
          child: Joystick(
            mode: JoystickMode.horizontalAndVertical,
            listener: (details) {
              BlocProvider.of<BlueControlBloc>(context).add(BlueControlSetDrivingDirection(x: details.x, y: details.y));
            },
          ),
        );
      },
    );
  }
}

class _Slider extends StatefulWidget {
  const _Slider({
    super.key,
    required this.device,
  });

  final BluetoothDevice device;

  @override
  State<_Slider> createState() => _SliderState();
}

class _SliderState extends State<_Slider> {
  double _value = 0.0;

  String serviceUUID = "0000FFE0-0000-1000-8000-00805F9B34FB";
  String uuidShort = "ffe0";

  Future<void> writeData(double val) async {
    widget.device.discoverServices().then((blueServices) async {
      final blueService = blueServices.firstWhere((element) => element.serviceUuid.str == "ffe0");
      final c = blueService.characteristics.first;

      String textToSend = "val: ${val.toStringAsFixed(0)}";
      List<int> data = utf8.encode(textToSend);
      await c.write(data, withoutResponse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SfSlider(
      min: 0.0,
      max: 100.0,
      value: _value,
      shouldAlwaysShowTooltip: true,
      interval: 10.0,
      stepSize: 5.0,
      onChangeEnd: (val) async {
        await writeData(val);
      },
      onChanged: (val) async {
        setState(() {
          _value = val;
        });
      },
    );
  }
}
