// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_repository/firebase_repository.dart';

part 'dht_state.dart';

class DhtCubit extends Cubit<DhtState> {
  DhtCubit({required FirebaseRepository firebaseRepository})
      : _firebaseRepository = firebaseRepository,
        super(DhtLoading());

  final FirebaseRepository _firebaseRepository;

  void loadData() async {
    try {
      DataSnapshot snapshot = await _firebaseRepository.getDHTReading();

      Map<String, dynamic> map = (snapshot.value as Map<Object?, Object?>).cast<String, dynamic>();

      DHT dht = DHT.fromMap(map);

      emit(DhtSucess(dht: dht));
    } catch (e) {
      emit(const DhtFailure());
    }
  }
}
