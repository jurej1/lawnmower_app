// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

enum RobotStatus {
  mowing,
  sleeping,
  charging,
}

extension WorkStatusX on RobotStatus {
  bool get isMowing => this == RobotStatus.mowing;
  bool get isSleeping => this == RobotStatus.sleeping;
  bool get isCharging => this == RobotStatus.charging;
}

class RobotInfo extends Equatable {
  final RobotStatus status;
  final int batteryState;
  final DateTime? startTime;
  final double area;
  final Duration estimatedDuration;
  final int atPoint;
  final int pathLength;

  const RobotInfo({
    required this.status,
    required this.batteryState,
    required this.startTime,
    required this.area,
    required this.estimatedDuration,
    required this.atPoint,
    required this.pathLength,
  });

  @override
  List<Object?> get props {
    return [
      status,
      batteryState,
      startTime,
      area,
      estimatedDuration,
      atPoint,
      pathLength,
    ];
  }

  RobotInfo copyWith({
    RobotStatus? status,
    int? batteryState,
    DateTime? startTime,
    double? area,
    Duration? estimatedDuration,
    int? atPoint,
    int? pathLength,
  }) {
    return RobotInfo(
      status: status ?? this.status,
      batteryState: batteryState ?? this.batteryState,
      startTime: startTime ?? this.startTime,
      area: area ?? this.area,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      atPoint: atPoint ?? this.atPoint,
      pathLength: pathLength ?? this.pathLength,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status.name,
      'batteryState': batteryState,
      'startTime': startTime?.millisecondsSinceEpoch,
      'area': area,
      'estimatedDuration': estimatedDuration.inSeconds,
      'atPoint': atPoint,
      'pathLength': pathLength,
    };
  }

  factory RobotInfo.fromMap(Map<String, dynamic> map) {
    return RobotInfo(
      status: RobotStatus.values.firstWhere((element) => element.name == map["status"]),
      batteryState: map['batteryState'] as int,
      startTime: map['startTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int) : null,
      area: map['area'] as double,
      estimatedDuration: Duration(seconds: map["estimatedDuration"]),
      atPoint: map['atPoint'] ?? 0,
      pathLength: map['pathLength'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory RobotInfo.fromJson(String source) => RobotInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  DateTime? get estimatedEndTime => startTime?.add(estimatedDuration);
}
