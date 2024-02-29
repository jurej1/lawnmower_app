// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class Schedule extends Equatable {
  final String id;
  final DateTime time;

  const Schedule({
    required this.id,
    required this.time,
  });

  @override
  List<Object> get props => [id, time];

  Schedule copyWith({
    String? id,
    DateTime? time,
  }) {
    return Schedule(
      id: id ?? this.id,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'time': time.millisecondsSinceEpoch,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Schedule.fromJson(String source) => Schedule.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
