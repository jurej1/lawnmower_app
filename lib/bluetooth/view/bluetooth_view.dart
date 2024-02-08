import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/bluetooth/view/control_device_view.dart';

import '../blocs/blue_scan/blue_scan_cubit.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothView extends StatelessWidget {
  const BluetoothView({super.key});

  static route() {
    return MaterialPageRoute(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => BlueScanCubit()..startScan()),
          ],
          child: const BluetoothView(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth View'),
      ),
      body: const Discovery(),
    );
  }
}

class Discovery extends StatefulWidget {
  const Discovery({super.key});

  @override
  State<Discovery> createState() => _DiscoveryState();
}

class _DiscoveryState extends State<Discovery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BlueScanCubit, BlueScanState>(
        builder: (c, state) {
          return ListView.separated(
            itemCount: state.devices.length,
            itemBuilder: (c, i) {
              final item = state.devices[i];
              return ListTile(
                title: Text(
                  item.remoteId.str,
                  style: TextStyle(
                    color: item.remoteId.str == "88:C2:55:D5:35:AE" ? Colors.red : Colors.white,
                  ),
                ),
                onTap: () async {
                  // item.connect().then((value) {
                  //   Navigator.pushReplacement(context, ControlDeviceView.route(item)).then((value) => item.disconnect());
                  // });
                  Navigator.pushReplacement(context, ControlDeviceView.route(item));
                },
              );
            },
            separatorBuilder: (c, i) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 5),
                color: Colors.black,
                height: 2,
              );
            },
          );
        },
      ),
    );
  }
}
