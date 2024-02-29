import 'dart:async';

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
  }

  final FirebaseRepository _firebaseRepository;

  FutureOr<void> _mapLoadToState(ScheduleListLoad event, Emitter<ScheduleListState> emit) async {
    try {
      DataSnapshot snapshot = await _firebaseRepository.getSchedulesList();
      final data = (snapshot.value as List<dynamic>).map<Schedule>((e) => Schedule.fromMap(e)).toList();

      emit(ScheduleListSuccess(schedules: data));
    } catch (e) {
      emit(ScheduleListFail());
    }
  }
}
