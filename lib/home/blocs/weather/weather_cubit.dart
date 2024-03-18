import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_state.dart';

// Klasse für Wetterzustandsverwaltung mit Cubit
class WeatherCubit extends Cubit<WeatherState> {
  // Konstruktor mit WeatherRepository
  WeatherCubit({
    required WeatherRepository weatherRepository,
  })  : _weatherRepository = weatherRepository,
        super(WeatherLoading()); // Startzustand ist 'Laden'

  final WeatherRepository _weatherRepository; // Repository für Wetterdaten

  // Holt Wetterinfos asynchron
  Future<void> getWeatherInfo() async {
    try {
      // Aktuelle Daten für einen Ort abfragen
      WeatherLocation? location = await _weatherRepository.getCurrentData("Murska Sobota");

      // Zustand bei Erfolg oder Misserfolg ändern
      if (location != null) {
        emit(WeatherSuccess(weatherLocation: location));
      } else {
        emit(WeatherFailure());
      }
    } catch (e) {
      emit(WeatherFailure()); // Zustand bei Fehler ändern
    }
  }
}
