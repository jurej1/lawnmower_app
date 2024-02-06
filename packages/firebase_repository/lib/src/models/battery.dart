// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class Battery extends Equatable {
  final bool isCharging;
  final int val;
  final DateTime dateTime;

  const Battery({
    required this.isCharging,
    required this.val,
    required this.dateTime,
  });

  @override
  List<Object> get props => [isCharging, val, dateTime];

  Battery copyWith({
    bool? isCharging,
    int? val,
    DateTime? dateTime,
  }) {
    return Battery(
      isCharging: isCharging ?? this.isCharging,
      val: val ?? this.val,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isCharging': isCharging,
      'val': val,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  factory Battery.fromMap(Map<String, dynamic> map) {
    return Battery(
      isCharging: map['isCharging'] as bool,
      val: map['val'] as int,
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Battery.fromJson(String source) => Battery.fromMap(json.decode(source) as Map<String, dynamic>);
}
