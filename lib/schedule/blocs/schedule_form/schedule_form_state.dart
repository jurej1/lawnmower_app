// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'schedule_form_bloc.dart';

class ScheduleFormState extends Equatable {
  const ScheduleFormState({
    required this.dateInput,
    required this.status,
  });

  final DateInput dateInput;
  final FormzSubmissionStatus status;

  @override
  List<Object> get props => [dateInput, status];

  ScheduleFormState copyWith({
    DateInput? dateInput,
    FormzSubmissionStatus? status,
  }) {
    return ScheduleFormState(
      dateInput: dateInput ?? this.dateInput,
      status: status ?? this.status,
    );
  }
}
