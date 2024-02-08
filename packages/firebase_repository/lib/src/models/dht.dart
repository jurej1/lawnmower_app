// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class DHT extends Equatable {
  final int humidity;
  final int temperature;

  const DHT({
    required this.humidity,
    required this.temperature,
  });
  @override
  List<Object> get props => [humidity, temperature];

  DHT copyWith({
    int? humidity,
    int? temperature,
  }) {
    return DHT(
      humidity: humidity ?? this.humidity,
      temperature: temperature ?? this.temperature,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'humidity': humidity,
      'temperature': temperature,
    };
  }

  factory DHT.fromMap(Map<String, dynamic> map) {
    return DHT(
      humidity: map['humidity'] as int,
      temperature: map['temperature'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory DHT.fromJson(String source) => DHT.fromMap(json.decode(source) as Map<String, dynamic>);
}
