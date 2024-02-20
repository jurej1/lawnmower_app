import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location/location.dart';

part 'user_location_state.dart';

class UserLocationCubit extends Cubit<UserLocationState> {
  UserLocationCubit() : super(const UserLocationLoading());

  final Location location = Location();

  Future<PermissionStatus> requestPermission() async {
    try {
      final permission = await location.requestPermission();

      log(permission.toString());
      return permission;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final hasPermission = await location.hasPermission();

      if (hasPermission == PermissionStatus.granted) {
        final locationData = await location.getLocation();
        emit(UserLocationLoaded(locationData: locationData));
      } else {
        final permission = await requestPermission();

        if (permission == PermissionStatus.granted) {
          final locationData = await location.getLocation();
          emit(UserLocationLoaded(locationData: locationData));
        }
      }
    } on Exception catch (_) {
      emit(const UserLocationFail());
    }
  }
}
