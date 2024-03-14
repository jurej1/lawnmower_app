import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_repository/firebase_repository.dart';

part 'schedule_list_event.dart';
part 'schedule_list_state.dart';

class ScheduleListBloc extends Bloc<ScheduleListEvent, ScheduleListState> {
  ScheduleListBloc({required FirebaseRepository firebaseRepository})
      : _firebaseRepository = firebaseRepository,
        super(ScheduleListLoading()) {
    on<ScheduleListLoad>(_mapLoadToState);
    on<ScheduleListItemAdded>(_mapAddedToState);
    on<ScheduleListRemoveItem>(_mapRemoveToState);
  }

  final FirebaseRepository _firebaseRepository;

  FutureOr<void> _mapLoadToState(ScheduleListLoad event, Emitter<ScheduleListState> emit) async {
    try {
      DataSnapshot snapshot = await _firebaseRepository.getSchedulesList();
      final data = (snapshot.value as Map<Object?, Object?>).cast<String, dynamic>();

      final dataFiltered = data
          .map((key, value) => MapEntry(
                key,
                Schedule(
                  id: key,
                  time: DateTime.fromMillisecondsSinceEpoch(value["time"]),
                ),
              ))
          .values
          .toList();

      emit(ScheduleListSuccess(schedules: dataFiltered));
    } catch (e) {
      log(e.toString());
      emit(ScheduleListFail());
    }
  }

  FutureOr<void> _mapAddedToState(ScheduleListItemAdded event, Emitter<ScheduleListState> emit) async {
    if (state is ScheduleListSuccess) {
      List<Schedule> list = List.from((state as ScheduleListSuccess).schedules);

      list
        ..add(event.schedule)
        ..sort();

      emit(ScheduleListSuccess(schedules: list));
    }
  }

  FutureOr<void> _mapRemoveToState(ScheduleListRemoveItem event, Emitter<ScheduleListState> emit) async {
    if (state is ScheduleListSuccess) {
      List<Schedule> list = List.from((state as ScheduleListSuccess).schedules);
    }
  }
}
