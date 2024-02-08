import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/bluetooth/view/bluetooth_view.dart';
import 'package:lawnmower_app/home/blocs/blocs.dart';
import 'package:lawnmower_app/home/widgets/widgets.dart';
import 'package:weather_repository/weather_repository.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

import '../../map/view/view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static Widget provider() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WeatherCubit(
            weatherRepository: RepositoryProvider.of<WeatherRepository>(context),
          )..getWeatherInfo(),
        ),
      ],
      child: const HomeView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(BluetoothView.route());
                  },
                  child: const Text('BLE'),
                ),
                const Spacer(),
                const WeatherDisplayer(),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Mowing",
              style: TextStyle(
                color: Colors.green,
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 5,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                ),
                child: const FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  heightFactor: 1,
                  widthFactor: 0.4,
                  child: ColoredBox(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const _ActionRow(),
            const SizedBox(height: 20),
            Container(
              height: 210,
              width: size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/rasen_roboter_catia.jpg')),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Mowing Session Ends at 23:00"),
            const SizedBox(height: 30),
            LiteRollingSwitch(
              width: 200,
              value: false,
              textOn: 'eating grass',
              textOff: 'on vacation...',
              colorOn: Colors.greenAccent.shade700,
              colorOff: Colors.redAccent.shade700,
              iconOn: Icons.check,
              iconOff: Icons.beach_access,
              // textSize: 16.0,
              textOnColor: Colors.white,
              onChanged: (bool state) {
                // TODO use this one.
              },
              onTap: () {},
              onDoubleTap: () {},
              onSwipe: () {},
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MapView.route(context));
              },
              icon: const Icon(Icons.location_on),
              label: const Text("Open Google Maps"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.cut),
        const Text("6"),
        const SizedBox(width: 10),
        _verticalBox(),
        const SizedBox(width: 10),
        const Icon(Icons.location_on),
        const Text("Front yard"),
        const SizedBox(width: 10),
        _verticalBox(),
        const SizedBox(width: 10),
        BatteryDisplayer.provider(),
      ],
    );
  }

  Widget _verticalBox() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.grey,
    );
  }
}
