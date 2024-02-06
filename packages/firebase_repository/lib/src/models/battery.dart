// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class Battery extends Equatable {
  final bool isCharging;
  final int val;

  const Battery({
    required this.isCharging,
    required this.val,
  });

  @override
  List<Object> get props => [isCharging, val];

  Battery copyWith({
    bool? isCharging,
    int? val,
  }) {
    return Battery(
      isCharging: isCharging ?? this.isCharging,
      val: val ?? this.val,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isCharging': isCharging,
      'val': val,
    };
  }

  factory Battery.fromMap(Map<String, dynamic> map) {
    return Battery(
      isCharging: map['isCharging'] as bool,
      val: map['val'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Battery.fromJson(String source) => Battery.fromMap(json.decode(source) as Map<String, dynamic>);
}
