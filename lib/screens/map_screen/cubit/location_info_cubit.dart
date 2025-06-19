import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jeas/screens/map_screen/cubit/location_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationLoading());

  Future<void> getInitialLocation(String person) async {
    SharedPreferences credit = await SharedPreferences.getInstance();
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(person)
          .doc(credit.getString("credential"))
          .get();
      final lat = snapshot['latitude'] as double;
      final lon = snapshot['longitude'] as double;
      emit(LocationLoaded(lat: lat, lon: lon));
    } catch (_) {
      emit(LocationError());
    }
  }
}
