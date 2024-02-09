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
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("${state.weatherLocation.tempC.toStringAsFixed(1)} °C"),
              const SizedBox(width: 6),
              Image.asset(
                state.weatherLocation.iconPath,
                package: "weather_repository",
                height: 50,
              ),
              const SizedBox(width: 6),
              Text(state.weatherLocation.conditionText),
            ],
          );
        }
        return Container();
      },
    );
  }
}
