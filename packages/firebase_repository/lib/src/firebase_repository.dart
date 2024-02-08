import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_database/firebase_database.dart';
// https://firebase.flutter.dev/docs/database/start
// visit this link to complete

class FirebaseRepository {
  FirebaseRepository({FirebaseDatabase? firebaseDatabase}) : _database = firebaseDatabase ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

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

    return _database.ref("cut_area").set(jsonData);
  }

  Future<void> setCutPath(List<LatLng> path) async {
    final jsonData = path
        .map((e) => {
              "lat": e.latitude,
              "lng": e.longitude,
            })
        .toList();

    return _database.ref("cut_path").set(jsonData);
  }

  Future<DataSnapshot> getCutArea() async {
    return _database.ref("cut_area").get();
  }

  Future<DataSnapshot> getCutPath() async {
    return _database.ref("cut_path").get();
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
