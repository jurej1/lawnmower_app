part of 'weather_cubit.dart';

class WeatherState extends Equatable {
  const WeatherState();
  @override
  List<Object?> get props => [];
}

class WeatherLoading extends WeatherState {}

class WeatherSuccess extends WeatherState {
  final WeatherLocation weatherLocation;

  const WeatherSuccess({required this.weatherLocation});

  @override
  List<Object?> get props => [weatherLocation];
}

class WeatherFailure extends WeatherState {}
