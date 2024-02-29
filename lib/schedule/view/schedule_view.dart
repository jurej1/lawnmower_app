import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lawnmower_app/schedule/schedule.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  static route() {
    return MaterialPageRoute(
      builder: (context) {
        return BlocProvider(
          create: (context) => ScheduleListBloc(
            firebaseRepository: RepositoryProvider.of<FirebaseRepository>(context),
          )..add(ScheduleListLoad()),
          child: const ScheduleView(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedules"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
