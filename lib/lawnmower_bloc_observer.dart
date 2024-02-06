import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

class LawnmowerBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    log(transition.toString());
    super.onTransition(bloc, transition);
  }
}
