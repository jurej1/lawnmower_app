import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_database/firebase_database.dart';
// https://firebase.flutter.dev/docs/database/start
// visit this link to complete

class FirebaseRepository {
  FirebaseRepository({FirebaseDatabase? firebaseDatabase}) : _database = firebaseDatabase ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  final _firebaseURL = "https://lawnmower-825c3-default-rtdb.europe-west1.firebasedatabase.app/";

  String get firebaseUrl => _firebaseURL;

  Future<DataSnapshot> getBatteryVal() async {
    return _database.ref("battery").get();
  }

  Future<void> setCutArea(List<LatLng> values) async {
    final jsonData = values
        .map((e) => {
              "lat": e.latitude,
              "lng": e.longitude,
            })
        .toList();

    final jsonString = jsonEncode(jsonData);

    return _database.ref("cut_area").set(jsonString);
  }

  Future<void> setCutPath(List<LatLng> path) async {
    final jsonData = path
        .map((e) => {
              "lat": e.latitude,
              "lng": e.longitude,
            })
        .toList();

    final jsonString = jsonEncode(jsonData);
    return _database.ref("cut_path").set(jsonString);
  }

  Future<DataSnapshot> getCutArea() async {
    return _database.ref("cut_area").get();
  }

  Future<DataSnapshot> getCutPath() async {
    return _database.ref("cut_path").get();

    // final response = await http.get(Uri.parse(url));

    // if (response.statusCode == 200) {
    //   final List<dynamic> jsonData = jsonDecode(response.body);

    //   List<LatLng> result = jsonData.map((data) {
    //     return LatLng(
    //       data["lat"],
    //       data["lng"],
    //     );
    //   }).toList();

    //   return result;
    // } else {
    //   throw Exception('Failed to load cut path data');
    // }
  }

  Future<DataSnapshot> getCurrentRobotLocation() async {
    return _database.ref("GPS_current").get();
  }

  Future<DataSnapshot> getHomeBaseGPS() async {
    return _database.ref("GPS_homebase").get();
  }

  Future<DataSnapshot> getRobotLocation() async {
    return _database.ref("GPS_current").get();
  }

  Future<DataSnapshot> getDHTReading() async {
    return _database.ref("DHT").get();
  }
}
