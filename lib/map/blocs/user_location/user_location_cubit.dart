import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location/location.dart';

part 'user_location_state.dart';

class UserLocationCubit extends Cubit<UserLocationState> {
  UserLocationCubit() : super(const UserLocationLoading());

  final Location location = Location();

  Future<bool?> requestPermission() async {
    try {
      final permission = await location.requestPermission();
      return permission == PermissionStatus.granted;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      if (await requestPermission() ?? false) {
        final locationData = await location.getLocation();
        emit(UserLocationLoaded(locationData: locationData));
      }
    } on Exception catch (_) {
      emit(const UserLocationFail());
    }
  }
}
