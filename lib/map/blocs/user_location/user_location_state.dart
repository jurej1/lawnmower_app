// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'user_location_cubit.dart';

abstract class UserLocationState extends Equatable {
  const UserLocationState();

  @override
  List<Object?> get props => [];
}

class UserLocationLoading extends UserLocationState {
  const UserLocationLoading();
}

class UserLocationLoaded extends UserLocationState {
  final LocationData locationData;

  const UserLocationLoaded({required this.locationData});
  @override
  List<Object?> get props => [locationData];
}

class UserLocationFail extends UserLocationState {
  const UserLocationFail();
}
