import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/home/blocs/blocs.dart';

class DhtDisplayer extends StatelessWidget {
  const DhtDisplayer({super.key});

  static provider() {
    return BlocProvider(
      create: (context) => DhtCubit(
        firebaseRepository: RepositoryProvider.of<FirebaseRepository>(context),
      )..loadData(),
      child: const DhtDisplayer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DhtCubit, DhtState>(
      builder: (context, state) {
        if (state is DhtLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is DhtSucess) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Temp: ${state.dht.temperature}°C"),
                Text("Hum: ${state.dht.humidity}%"),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
