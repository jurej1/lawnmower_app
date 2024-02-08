part of 'dht_cubit.dart';

abstract class DhtState extends Equatable {
  const DhtState();

  @override
  List<Object> get props => [];
}

class DhtLoading extends DhtState {}

class DhtSucess extends DhtState {
  final DHT dht;

  const DhtSucess({required this.dht});

  @override
  List<Object> get props => [dht];
}

class DhtFailure extends DhtState {
  const DhtFailure();
}
