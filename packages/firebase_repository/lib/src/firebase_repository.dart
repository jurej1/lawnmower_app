import 'dart:convert';

import 'package:firebase_repository/src/models/battery.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'enums/speed.dart';

class FirebaseRepository {
  const FirebaseRepository();

  final _firebaseURL = "https://lawnmower-825c3-default-rtdb.europe-west1.firebasedatabase.app/";

  String get firebaseUrl => _firebaseURL;

  Future<void> setSpeedByDialog(Speed speed) async {
    final url = firebaseUrl + "speed.json";

    await http.put(Uri.parse(url), body: {
      'val': speed.mapSpeedToVal(),
    });
  }

  Future<void> setSpeedManual(double val) async {
    final url = firebaseUrl + "speed.json";

    await http.put(Uri.parse(url), body: {
      'val': val,
    });
  }

  Future<Battery> getBatteryVal() async {
    final url = firebaseUrl + "battery.json";

    final response = await http.get(Uri.parse(url));

    return Battery.fromJson(response.body);
  }

  Future<http.Response> setCutArea(List<LatLng> values) async {
    final url = firebaseUrl + "cut_area.json";

    final jsonData = values
        .map((e) => {
              "lat": e.latitude,
              "lng": e.longitude,
            })
        .toList();

    final jsonString = jsonEncode(jsonData);

    return http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonString,
    );
  }

  Future<List<LatLng>> getCutArea() async {
    final url = firebaseUrl + "cut_area.json";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

      List<LatLng> result = jsonData.map((data) {
        return LatLng(
          data["lat"],
          data["lng"],
        );
      }).toList();

      return result;
    } else {
      throw Exception('Failed to load cut area data');
    }
  }

  Future<LatLng> getCurrentRobotLocation() async {
    final url = firebaseUrl + "GPS_current.json";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dynamic jsonData = jsonDecode(response.body);

      LatLng location = LatLng(
        jsonData["lat"],
        jsonData["lng"],
      );

      return location;
    } else {
      throw Exception('Failed to load current robot location data');
    }
  }

  Future<LatLng> getHomeBaseGPS() async {
    final url = firebaseUrl + "GPS_homebase.json";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dynamic jsonData = jsonDecode(response.body);

      LatLng location = LatLng(
        jsonData["lat"],
        jsonData["lng"],
      );

      return location;
    } else {
      throw Exception('Failed to load current robot location data');
    }
  }

  Future<void> getRobotLocation() async {
    final url = firebaseUrl + "GPS_current.json";

    final response = await http.get(Uri.parse(url));

    return jsonDecode(response.body);
  }

  Future<void> getDHTReading() async {
    final url = firebaseUrl + "DHT.json";
    final response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }
}
