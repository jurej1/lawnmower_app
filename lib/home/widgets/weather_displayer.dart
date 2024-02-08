import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/weather/weather_cubit.dart';

class WeatherDisplayer extends StatelessWidget {
  const WeatherDisplayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherSuccess) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${state.weatherLocation.tempC.toStringAsFixed(1)} °C"),
                  Image.asset(
                    state.weatherLocation.iconPath,
                    package: "weather_repository",
                    height: 50,
                  ),
                  Text(state.weatherLocation.conditionText),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
