import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/firebase_options.dart';
import 'package:lawnmower_app/home/home.dart';
import 'package:lawnmower_app/lawnmower_bloc_observer.dart';
import 'package:lawnmower_app/map/blocs/blocs.dart';
import 'package:poly_repository/poly_repository.dart';
import 'package:weather_repository/weather_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Bloc.observer = LawnmowerBlocObserver();
  runApp(
    App(
      weatherRepository: const WeatherRepository(),
      firebaseRepository: FirebaseRepository(),
      polyRepository: const PolyRepository(),
    ),
  );
}

class App extends StatefulWidget {
  final WeatherRepository _weatherRepository;
  final FirebaseRepository _firebaseRepository;
  final PolyRepository _polyRepository;
  const App({
    super.key,
    required WeatherRepository weatherRepository,
    required FirebaseRepository firebaseRepository,
    required PolyRepository polyRepository,
  })  : _weatherRepository = weatherRepository,
        _firebaseRepository = firebaseRepository,
        _polyRepository = polyRepository;

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
        RepositoryProvider.value(value: widget._polyRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserLocationCubit>(
            lazy: false,
            create: (context) => UserLocationCubit()..getCurrentLocation(),
          ),
        ],
        child: MaterialApp(
          darkTheme: ThemeData.dark(),
          home: HomeView.provider(),
        ),
      ),
    );
  }
}
