import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit({
    required WeatherRepository weatherRepository,
  })  : _weatherRepository = weatherRepository,
        super(WeatherLoading());

  final WeatherRepository _weatherRepository;

  Future<void> getWeatherInfo() async {
    emit(WeatherLoading());
    try {
      // for this function do JSON response to Class Dart.
      WeatherLocation? location = await _weatherRepository.getCurrentData("Murska Sobota");

      if (location != null) {
        emit(WeatherSuccess(weatherLocation: location));
      } else {
        emit(WeatherFailure());
      }
    } catch (e) {
      emit(WeatherFailure());
    }
  }
}
