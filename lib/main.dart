import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/firebase_options.dart';
import 'package:lawnmower_app/home/home.dart';
import 'package:lawnmower_app/lawnmower_bloc_observer.dart';
import 'package:weather_repository/weather_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Bloc.observer = LawnmowerBlocObserver();
  runApp(
    const App(
      weatherRepository: WeatherRepository(),
      firebaseRepository: FirebaseRepository(),
    ),
  );
}

class App extends StatefulWidget {
  final WeatherRepository _weatherRepository;
  final FirebaseRepository _firebaseRepository;
  const App({
    super.key,
    required WeatherRepository weatherRepository,
    required FirebaseRepository firebaseRepository,
  })  : _weatherRepository = weatherRepository,
        _firebaseRepository = firebaseRepository;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget._weatherRepository),
        RepositoryProvider.value(value: widget._firebaseRepository),
      ],
      child: MaterialApp(
        home: HomeView.provider(),
      ),
    );
  }
}
