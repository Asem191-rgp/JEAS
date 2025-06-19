import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference requestCollection =
      FirebaseFirestore.instance.collection('requests');

  final CollectionReference workerCollection =
      FirebaseFirestore.instance.collection('workers');

  final CollectionReference customerCollection =
      FirebaseFirestore.instance.collection('customers');

  void acceptRequestService(
    String requestId,
    String requesterId,
  ) async {
    await requestCollection.doc(requestId).update({
      'workerUID': uid,
      'status': 'Accepted',
    });
    await workerCollection.doc(uid).update({
      "requests": FieldValue.arrayUnion([requestId]),
    });
    DocumentSnapshot requester =
        await customerCollection.doc(requesterId).get();
    print("requester: ${requester['fcmToken']}");
  }

  void completeRequestService(
    String requestId,
    String requesterId,
  ) async {
    await requestCollection.doc(requestId).update(
      {
        'workerUID': uid,
        'status': 'Completed',
      },
    );
  }

  void finishRequestService(
    String requestId,
    String requesterId,
  ) async {
    await requestCollection.doc(requestId).update(
      {
        'workerUID': uid,
        'status': 'Finishing',
      },
    );
  }

  void cancelRequestService(
    String requestId,
  ) async {
    await requestCollection.doc(requestId).update({
      'workerUID': null,
      'status': 'Pending',
    });

    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('workers').doc(uid).get();

    List<dynamic> newArray = List.from(documentSnapshot['requests']);
    newArray.remove(requestId);

    await workerCollection.doc(uid).update({
      "requests": newArray,
    });
  }

  void addFeedback(
    String senderName,
    String customerId,
    double rate,
    String text,
  ) async {
    await customerCollection.doc(customerId).update({
      "comments": FieldValue.arrayUnion(['$senderName::$text']),
    });
    await customerCollection.doc(customerId).update({
      "rates": FieldValue.arrayUnion([rate]),
    });
  }
}
