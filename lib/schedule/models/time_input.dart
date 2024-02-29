import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

enum TimeInputError { invalid }

class TimeInput extends FormzInput<TimeOfDay, TimeInputError> {
  const TimeInput.pure(super.value) : super.pure();
  const TimeInput.dirty(super.value) : super.dirty();

  @override
  TimeInputError? validator(TimeOfDay value) {
    return null;
  }
}
