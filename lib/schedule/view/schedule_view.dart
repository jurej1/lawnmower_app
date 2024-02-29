import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:lawnmower_app/schedule/schedule.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  static route() {
    return MaterialPageRoute(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ScheduleListBloc(
                firebaseRepository: RepositoryProvider.of<FirebaseRepository>(context),
              )..add(ScheduleListLoad()),
            ),
          ],
          child: const ScheduleView(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedules"),
        actions: [
          IconButton(
            onPressed: () async {
              final schedule = await showModalBottomSheet<Schedule?>(
                context: context,
                builder: (context) {
                  return BlocProvider(
                    create: (context) => ScheduleFormBloc(
                      firebaseRepository: RepositoryProvider.of<FirebaseRepository>(context),
                    ),
                    child: Builder(builder: (context) {
                      return Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            BlocConsumer<ScheduleFormBloc, ScheduleFormState>(
                              listener: (context, state) {
                                if (state.status.isSuccess) {
                                  Navigator.of(context).pop<Schedule?>(state.schedule);
                                }
                              },
                              builder: (context, state) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showDatePicker(
                                          context: context,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 365),
                                          ),
                                        );
                                      },
                                      child: Text(DateFormat(DateFormat.MONTH_WEEKDAY_DAY).format(state.dateInput.value)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(state.dateInput.value),
                                        );
                                      },
                                      child: Text(DateFormat(DateFormat.HOUR24_MINUTE).format(state.dateInput.value)),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        BlocProvider.of<ScheduleFormBloc>(context).add(ScheduleFormSubmit());
                                      },
                                      icon: state.status == FormzSubmissionStatus.inProgress
                                          ? const CircularProgressIndicator()
                                          : const Icon(Icons.check),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              );

              if (schedule != null) {
                BlocProvider.of<ScheduleListBloc>(context).add(ScheduleListItemAdded(schedule: schedule));
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocBuilder<ScheduleListBloc, ScheduleListState>(
        builder: (context, state) {
          if (state is ScheduleListLoading) {
            return const LinearProgressIndicator();
          } else if (state is ScheduleListSuccess) {
            return ListView.builder(
              itemCount: state.schedules.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(DateFormat().format(state.schedules[i].time)),
                );
              },
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
