import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/bluetooth/view/bluetooth_view.dart';
import 'package:lawnmower_app/home/blocs/blocs.dart';
import 'package:lawnmower_app/home/widgets/widgets.dart';
import 'package:weather_repository/weather_repository.dart';

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
        BlocProvider(
          create: (context) => RobotInfoCubit(
            firebaseRepository: RepositoryProvider.of<FirebaseRepository>(context),
          )..loadData(),
        ),
        BlocProvider(
          create: (context) => RobotLocationCubit(
            firebaseRepository: RepositoryProvider.of<FirebaseRepository>(context),
          )..loadData(),
        ),
      ],
      child: const HomeView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return Future.wait(
            [
              BlocProvider.of<WeatherCubit>(context).getWeatherInfo(),
              BlocProvider.of<RobotInfoCubit>(context).loadData(),
              BlocProvider.of<RobotLocationCubit>(context).loadData(),
            ],
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: size.height,
            width: size.width,
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
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 30),
                const StatusTextDisplayer(),
                const SizedBox(height: 15),
                const _ActionRow(),
                const SizedBox(height: 20),
                const ImageBuilder(),
                const SizedBox(height: 20),
                const SessionText(),
                const SizedBox(height: 30),
                const StatusSwitch(),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DhtDisplayer.provider(),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MapView.route(
                            context,
                            robotInfoCubit: BlocProvider.of<RobotInfoCubit>(context),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_on),
                      label: const Text("Open Google Maps"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImageBuilder extends StatelessWidget {
  const ImageBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotInfoCubit, RobotInfoState>(
      builder: (context, state) {
        if (state is RobotInfoSucess) {
          return Column(
            children: [
              CustomPaint(
                size: const Size(260, 260),
                foregroundPainter: state.robotInfo.status.isMowing
                    ? ProgressPainter(
                        index: state.robotInfo.atPoint,
                        fullLength: state.robotInfo.pathLength,
                        backgroundColor: Colors.green,
                      )
                    : state.robotInfo.status.isCharging
                        ? ProgressPainter(
                            index: state.robotInfo.batteryState,
                            fullLength: 100,
                            backgroundColor: Colors.blue,
                          )
                        : null,
                child: Container(
                  height: 260,
                  width: 260,
                  padding: const EdgeInsets.all(10),
                  child: Image.asset("assets/rasen_roboter_catia.jpg"),
                ),
              ),
              if (state.robotInfo.status.isMowing)
                Text(
                  "${(state.robotInfo.atPoint / state.robotInfo.pathLength * 100).round()} %",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 21,
                  ),
                ),
            ],
          );
        }
        return SizedBox(
          height: 260,
          width: 260,
          child: Image.asset("assets/rasen_roboter_catia.jpg"),
        );
      },
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({super.key});

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
        const RobotLocationIcon(),
        const SizedBox(width: 10),
        _verticalBox(),
        const SizedBox(width: 10),
        const BatteryDisplayer(),
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

class RobotLocationIcon extends StatelessWidget {
  const RobotLocationIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RobotLocationCubit, RobotLocationState>(
      builder: (context, state) {
        if (state is RobotLocationSuccess) {
          bool isHome = state.isOnBase;
          return Row(
            children: [
              Icon(isHome ? Icons.home : Icons.location_on),
              const SizedBox(width: 5),
              Text(isHome ? "In base" : "Front yard"),
            ],
          );
        }
        return Container();
      },
    );
  }
}
