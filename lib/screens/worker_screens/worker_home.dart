// ignore_for_file: use_build_context_synchronously, avoid_print, unused_field
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jeas/features/drawer.dart';
import 'package:jeas/screens/chat_screen/chats_page.dart';
import 'package:jeas/screens/worker_screens/worker_profile.dart';
import 'worker_requests_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:jeas/screens/common_screens/login.dart';
import 'package:jeas/screens/map_screen/get_location.dart';
import 'package:permission_handler/permission_handler.dart';

class WorkerHome extends StatefulWidget {
  const WorkerHome({super.key});

  @override
  State<WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  late Timer _locationTimer;
  late Timer _userTimer;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  dispose() {
    super.dispose();
    _locationTimer.cancel();
    _userTimer.cancel();
  }

  Future<void> initialize() async {
    try {
      var status = await Permission.location.status;

      if (status != PermissionStatus.granted) {
        status = await Permission.location.request();
        if (status != PermissionStatus.granted) {
          return;
        }
      }

      Position currentPosition = await Geolocator.getCurrentPosition();
      final userid = FirebaseAuth.instance.currentUser!.uid;
      final CollectionReference userCollection =
          FirebaseFirestore.instance.collection('workers');
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double lat = currentPosition.latitude;
      double lon = currentPosition.longitude;
      await userCollection.doc(userid).update({
        "latitude": lat,
        "longitude": lon,
      });
      _locationTimer =
          Timer.periodic(const Duration(minutes: 2), (timer) async {
        print("getting location***");
        currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double lat = currentPosition.latitude;
        double lon = currentPosition.longitude;
        try {
          await userCollection.doc(userid).update({
            "latitude": lat,
            "longitude": lon,
          });
        } catch (e) {
          print("Error getting latitude and longitude: $e");
        }
      });
    } catch (e) {
      print("ERROR: $e");
    }

    _userTimer =
        Timer.periodic(const Duration(minutes: 15), (Timer timer) async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is currently signed out!');
        print('Timer has been stopped');
        _locationTimer.cancel();
      } else {
        print('User is signed in!');
      }
    });

    final userStream = FirebaseFirestore.instance
        .collection('workers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    userStream.listen((snapshot) async {
      if (snapshot.exists) {
        var accountStatus = snapshot['status'];
        print("Account status: $accountStatus");
        if (accountStatus != 'activated') {
          _locationTimer.cancel();
          await FirebaseAuth.instance.signOut().then((value) =>
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        drawer: const MyDrawer("workers"),
        appBar: AppBar(
          toolbarHeight: 70,
          actions: const [
            Image(
              image: AssetImage('assets/images/logo.jpeg'),
              height: 70,
            ),
          ],
        ),
        bottomNavigationBar: const TabBar(isScrollable: false, tabs: [
          Tab(
            icon: Icon(
              Icons.person,
              size: 16,
            ),
            child: Text(
              "Profile",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
            ),
          ),
          Tab(
            icon: Icon(
              Icons.place,
              size: 16,
            ),
            child: Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
            ),
          ),
          Tab(
            icon: Icon(
              Icons.message,
              size: 16,
            ),
            child: Text(
              "Messages",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 7),
            ),
          ),
          Tab(
            icon: Icon(
              Icons.request_page,
              size: 16,
            ),
            child: Text(
              "Requests",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 7),
            ),
          ),
        ]),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Profile(),
            GetLocation("workers"),
            ChatsPage(personality: "workers"),
            WorkerRequestsScreen()
          ],
        ),
      ),
    );
  }
}
