// ignore_for_file: use_build_context_synchronously, unused_field, avoid_print
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jeas/features/drawer.dart';
import 'package:jeas/screens/chat_screen/tabbar_page.dart';
import 'package:jeas/screens/map_screen/get_location.dart';
import 'package:jeas/screens/common_screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jeas/screens/customer_screens/customer_profile.dart';
import 'requests_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  late Timer _locationTimer;
  late Timer _userTimer;
  final String _selectedItem = "Delete Account";
  final List<String> _items = ["Delete Account", "Documentation"];
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
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
      Position currentPosition = await Geolocator.getCurrentPosition();
      final userid = FirebaseAuth.instance.currentUser!.uid;
      final CollectionReference userCollection =
          FirebaseFirestore.instance.collection('customers');
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
        .collection('customers')
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
        drawer: const MyDrawer("customers"),
        appBar: AppBar(
          toolbarHeight: 70,
          actions: const [
            Image(
              image: AssetImage('assets/images/logo.jpeg'),
              height: 70,
            ),
          ],
        ),
        bottomNavigationBar: const TabBar(tabs: [
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
              Icons.post_add,
              size: 16,
            ),
            child: Text(
              "Request",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
            ),
          ),
        ]),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const CustomerProfile(),
            const GetLocation("customers"),
            const TabbedPage(personality: 'customers'),
            RequestsScreen(),
          ],
        ),
      ),
    );
  }
}
