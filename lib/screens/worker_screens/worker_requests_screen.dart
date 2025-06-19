// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_details_worker_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';

Map<String, dynamic> workerData = {};

class WorkerRequestsScreen extends StatefulWidget {
  const WorkerRequestsScreen({super.key});

  @override
  State<WorkerRequestsScreen> createState() => _WorkerRequestsScreenState();
}

class _WorkerRequestsScreenState extends State<WorkerRequestsScreen> {
  final CollectionReference serviceRequests =
      FirebaseFirestore.instance.collection('requests');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Requested Services'),
      ),
      body: StreamBuilder(
        stream: serviceRequests.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;

          return FutureBuilder<void>(
            future: _getFilteredDocuments(documents),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              List<DocumentSnapshot> filteredDocuments =
                  snapshot.data as List<DocumentSnapshot>;

              return filteredDocuments.isEmpty
                  ? const Center(
                      child: Text('No requests'),
                    )
                  : ListView.builder(
                      itemCount: filteredDocuments.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = filteredDocuments[index]
                            .data() as Map<String, dynamic>;

                        Color tileColor =
                            index.isEven ? Colors.blue[50]! : Colors.blue[100]!;
                        return Card(
                          color: tileColor,
                          child: ListTile(
                            title: Text(data['title']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Location: ${data['location']}'),
                                Text(
                                    'Service Category: ${data['serviceCategory']}'),
                              ],
                            ),
                            trailing: FutureBuilder<String?>(
                              future:
                                  _getRequesterPhotoUrl(data['requesterUID']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasData) {
                                  return CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(snapshot.data!),
                                  );
                                } else {
                                  return const Icon(Icons.person);
                                }
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ServiceDetailsWorkerScreen(data: data),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
            },
          );
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> _getFilteredDocuments(
      List<DocumentSnapshot> documents) async {
    List<DocumentSnapshot> filteredDocuments = [];

    for (DocumentSnapshot document in documents) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      await _getWorkerInfo(FirebaseAuth.instance.currentUser!.uid);

      double workerLatitude = workerData['latitude'];
      double workerLongitude = workerData['longitude'];
      double customerLatitude = data['latitude'];
      double customerLongitude = data['longitude'];

      String workerSkill = _extractCategory(workerData['skills']);

      double distance = _calculateDistance(
          workerLatitude, workerLongitude, customerLatitude, customerLongitude);

      print(workerData['created-at']);
      int timeDiff =
          timeDifference(data['created-at'].toDate(), DateTime.now());

      if (((FirebaseAuth.instance.currentUser!.uid == data['workerUID'] &&
                  (data['status'] == 'Accepted' ||
                      data['status'] == 'Completed' ||
                      data['status'] == 'Finishing')) ||
              data['status'] == 'Pending') &&
          ((timeDiff <= 10 && distance <= 10) ||
              timeDiff > 10 && distance <= 60) &&
          data['serviceCategory'] == workerSkill) {
        filteredDocuments.add(document);
      }
      print("timeDiff: $timeDiff");
      print("distance: $distance");
      print("data: $data");
    }

    return filteredDocuments;
  }

  Future<void> _getWorkerInfo(String workerId) async {
    try {
      DocumentSnapshot workerSnapshot = await FirebaseFirestore.instance
          .collection('workers')
          .doc(workerId)
          .get();
      if (workerSnapshot.exists) {
        workerData = workerSnapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('Worker not found');
      }
    } catch (e) {
      throw Exception('Error fetching worker information: $e');
    }
  }

  Future<String?> _getRequesterPhotoUrl(String? requesterUid) async {
    if (requesterUid == null) return null;

    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('$requesterUid/ProfileImage.jpg');
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error retrieving photo: $e');
      return null;
    }
  }

  double _calculateDistance(
      double latit1, double long1, double latit2, double long2) {
    const earthRadius = 6371; // Earth's radius in kilometers

    final lat1 = _radians(latit1);
    final lon1 = _radians(long1);
    final lat2 = _radians(latit2);
    final lon2 = _radians(long2);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = earthRadius * c;
    return distance;
  }

  double _radians(double degrees) {
    return degrees * pi / 180;
  }

  String _extractCategory(String input) {
    int indexOfLastParenthesis = input.lastIndexOf("(");
    return input.substring(0, indexOfLastParenthesis).trim();
  }

  int timeDifference(DateTime d1, DateTime d2) {
    Duration difference = d2.difference(d1);
    return difference.inMinutes.abs();
  }
}
