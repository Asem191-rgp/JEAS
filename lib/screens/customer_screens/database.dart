// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference requestCollection =
      FirebaseFirestore.instance.collection('requests');

  final CollectionReference customerCollection =
      FirebaseFirestore.instance.collection('customers');

  final CollectionReference workerCollection =
      FirebaseFirestore.instance.collection('workers');
  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location services are disabled.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void requestService(
    String location,
    String title,
    String description,
    String serviceCategory,
    String requestId,
  ) async {
    final pos = await getLocation();
    await requestCollection.doc(requestId).set({
      'uid': requestId,
      'requesterUID': uid,
      'location': location,
      'title': title,
      'description': description,
      'serviceCategory': serviceCategory,
      'workerUID': null,
      'status': 'Pending',
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'created-at': DateTime.now()
    });
    await customerCollection.doc(uid).update({
      "requests": FieldValue.arrayUnion([requestId]),
    });
  }

  void completeRequestService(
    String requestId,
  ) async {
    await requestCollection.doc(requestId).update(
      {
        'status': 'Completed',
      },
    );
  }

  void deleteRequestService(String requestId) async {
    try {
      // Check if the document exists before attempting deletion
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .get();

      if (documentSnapshot.exists) {
        DocumentReference userDocRef = customerCollection.doc(uid);

        DocumentSnapshot userSnapshot = await userDocRef.get();
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;
        List<dynamic> newArray = List.from(userData?['requests'] ?? []);
        newArray.remove(requestId);
        await userDocRef.update({"requests": newArray});
        await requestCollection.doc(requestId).delete();
        var result =
            await FirebaseStorage.instance.ref('requests/$requestId').listAll();
        await Future.forEach(result.items, (Reference ref) async {
          await ref.delete();
        });

        print('Request $requestId deleted successfully.');
      } else {
        print('Document with ID $requestId does not exist.');
      }
    } catch (e) {
      print('Error deleting request: $e');
    }
  }

  void addFeedback(
    String senderName,
    String workerId,
    double rate,
    String text,
  ) async {
    await workerCollection.doc(workerId).update({
      "comments": FieldValue.arrayUnion(['$senderName::$text']),
    });
    await workerCollection.doc(workerId).update({
      "rates": FieldValue.arrayUnion([rate]),
    });
  }
}
