import 'package:formz/formz.dart';

enum DateInputError { invalid }

class DateInput extends FormzInput<DateTime, DateInputError> {
  const DateInput.pure(super.value) : super.pure();
  const DateInput.dirty(super.value) : super.dirty();

  @override
  DateInputError? validator(DateTime value) {
    return value.isBefore(DateTime.now()) ? DateInputError.invalid : null;
  }
}
