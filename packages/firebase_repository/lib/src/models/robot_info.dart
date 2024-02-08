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
  final DateTime? estimatedEndTime;

  const RobotInfo({
    required this.status,
    required this.startTime,
    required this.estimatedEndTime,
    required this.batteryState,
  });

  @override
  List<Object?> get props => [status, startTime, estimatedEndTime, batteryState];

  RobotInfo copyWith({
    RobotStatus? status,
    DateTime? startTime,
    DateTime? estimatedEndTime,
    int? batteryState,
  }) {
    return RobotInfo(
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      estimatedEndTime: estimatedEndTime ?? this.estimatedEndTime,
      batteryState: batteryState ?? this.batteryState,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status.name,
      'startTime': startTime?.millisecondsSinceEpoch,
      'estimatedEndTime': estimatedEndTime?.millisecondsSinceEpoch,
      'batteryState': batteryState,
    };
  }

  factory RobotInfo.fromMap(Map<String, dynamic> map) {
    return RobotInfo(
      status: RobotStatus.values.firstWhere((element) => element.name == map['status']),
      startTime: map['startTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int) : null,
      estimatedEndTime: map['estimatedEndTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['estimatedEndTime'] as int) : null,
      batteryState: map['batteryState'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory RobotInfo.fromJson(String source) => RobotInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
