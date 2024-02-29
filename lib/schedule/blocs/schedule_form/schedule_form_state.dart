// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'schedule_form_bloc.dart';

class ScheduleFormState extends Equatable {
  const ScheduleFormState({
    required this.dateInput,
    required this.timeInput,
    required this.status,
    required this.isValid,
    this.schedule,
  });

  final DateInput dateInput;
  final TimeInput timeInput;
  final FormzSubmissionStatus status;
  final bool isValid;
  final Schedule? schedule;

  @override
  List<Object?> get props {
    return [
      dateInput,
      timeInput,
      status,
      isValid,
      schedule,
    ];
  }

  ScheduleFormState copyWith({
    DateInput? dateInput,
    TimeInput? timeInput,
    FormzSubmissionStatus? status,
    bool? isValid,
    Schedule? schedule,
  }) {
    return ScheduleFormState(
      dateInput: dateInput ?? this.dateInput,
      timeInput: timeInput ?? this.timeInput,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      schedule: schedule ?? this.schedule,
    );
  }
}
