import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DistanceForCustomer extends StatefulWidget {
  final String requestId;
  const DistanceForCustomer({required this.requestId, super.key});

  @override
  State<DistanceForCustomer> createState() => _DistanceForCustomerState();
}

class _DistanceForCustomerState extends State<DistanceForCustomer> {
  double? workerlat;
  double? workerlong;
  double? distance;
  Timer? time;

  @override
  initState() {
    super.initState();
    time = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        updateWorkerLocation();
      });
    });
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

    final distance = earthRadius * c * 1000; // Convert to meters
    return distance;
  }

  double _radians(double degrees) {
    return degrees * pi / 180;
  }

  Future<double> updateWorkerLocation() async {
    final requestData = await FirebaseFirestore.instance
        .collection("requests")
        .doc(widget.requestId)
        .get();
    String workerId = requestData['workerUID'];
    final workerData = await FirebaseFirestore.instance
        .collection("workers")
        .doc(workerId)
        .get();
    final customerData = await FirebaseFirestore.instance
        .collection("customers")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    workerlat = workerData["latitude"];
    workerlong = workerData["longitude"];
    distance = _calculateDistance(workerlat!, workerlong!,
        customerData["latitude"], customerData["longitude"]);

    // Stop updating if distance is less than 10 meters
    if (distance! < 10) {
      time!.cancel();
    }

    return distance!;
  }

  @override
  void dispose() {
    time!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Image(
            image: AssetImage('assets/images/logo.jpeg'),
            height: 100,
          ),
        ],
      ),
      body: FutureBuilder(
        future: updateWorkerLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          if (distance! < 10) {
            return const Center(
              child: Text(
                "The Worker is Here",
                style: TextStyle(fontSize: 24, color: Colors.green),
              ),
            );
          }
          return Center(
            child: Text(
              "Distance Between you and the worker is :\n${snapshot.data} meters",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          );
        },
      ),
    );
  }
}
