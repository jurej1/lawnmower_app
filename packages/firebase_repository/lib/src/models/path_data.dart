// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class PathData extends Equatable {
  final double cutArea;
  final Duration duration;
  final double length;

  PathData({
    required this.cutArea,
    required this.duration,
    required this.length,
  });

  @override
  List<Object> get props => [cutArea, duration, length];

  PathData copyWith({
    double? cutArea,
    Duration? duration,
    double? length,
  }) {
    return PathData(
      cutArea: cutArea ?? this.cutArea,
      duration: duration ?? this.duration,
      length: length ?? this.length,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cutArea': cutArea,
      'duration': duration.inSeconds,
      'length': length,
    };
  }

  factory PathData.fromMap(Map<String, dynamic> map) {
    return PathData(
      cutArea: map['cutArea'] as double,
      duration: Duration(seconds: map['duration']),
      length: map['length'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory PathData.fromJson(String source) => PathData.fromMap(json.decode(source) as Map<String, dynamic>);
}
