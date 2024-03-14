import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:lawnmower_app/schedule/models/models.dart';

part 'schedule_form_event.dart';
part 'schedule_form_state.dart';

class ScheduleFormBloc extends Bloc<ScheduleFormEvent, ScheduleFormState> {
  ScheduleFormBloc({
    required FirebaseRepository firebaseRepository,
  })  : _firebaseRepository = firebaseRepository,
        super(
          ScheduleFormState(
            dateInput: DateInput.pure(DateTime.now()),
            status: FormzSubmissionStatus.initial,
            timeInput: TimeInput.pure(TimeOfDay.now()),
            isValid: true,
          ),
        ) {
    on<ScheduleFormDateUpdated>(_mapDateUpdatedToState);
    on<ScheduleFormTimeUpdated>(_mapTimeUpdatedToState);
    on<ScheduleFormSubmit>(_mapSubmitToState);
  }

  final FirebaseRepository _firebaseRepository;

  FutureOr<void> _mapDateUpdatedToState(ScheduleFormDateUpdated event, Emitter<ScheduleFormState> emit) {
    final newVal = DateInput.dirty(event.date);

    emit(
      state.copyWith(
        dateInput: newVal,
        isValid: Formz.validate([newVal, state.timeInput]),
      ),
    );
  }

  FutureOr<void> _mapTimeUpdatedToState(ScheduleFormTimeUpdated event, Emitter<ScheduleFormState> emit) {
    final newVal = TimeInput.pure(event.timeOfDay);

    emit(
      state.copyWith(
        timeInput: newVal,
        isValid: Formz.validate([newVal, state.dateInput]),
      ),
    );
  }

  FutureOr<void> _mapSubmitToState(ScheduleFormSubmit event, Emitter<ScheduleFormState> emit) async {
    emit(state.copyWith(isValid: Formz.validate([state.dateInput, state.timeInput])));

    if (state.isValid) {
      try {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.inProgress,
          ),
        );

        final stateDate = state.dateInput.value;
        final stateTime = state.timeInput.value;

        Schedule schedule = Schedule(
          id: UniqueKey().toString(),
          time: DateTime(
            stateDate.year,
            stateDate.month,
            stateDate.day,
            stateTime.hour,
            stateTime.minute,
          ),
        );

        DatabaseReference ref = await _firebaseRepository.addSchedule(schedule);

        emit(
          state.copyWith(
            status: FormzSubmissionStatus.success,
            schedule: schedule.copyWith(id: ref.key),
          ),
        );
      } catch (e) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    }
  }
}
