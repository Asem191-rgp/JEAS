// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jeas/screens/worker_screens/worker_home.dart';
import 'package:jeas/screens/customer_screens/customer_home.dart';
import 'package:jeas/screens/common_screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDA9o9IstmkvhXEapITudeauRvxTpJ7D30',
      appId: '1:467649563037:android:2d69e836003ba151a7c774',
      messagingSenderId: '467649563037',
      projectId: 'jeas-cfe02',
      storageBucket: 'jeas-cfe02.appspot.com',
    ),
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? personality;

  @override
  void initState() {
    super.initState();
    checkUser();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
    });
  }

  Future<void> checkUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null && user.emailVerified) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('credential');

      if (userId != null && userId.isNotEmpty) {
        try {
          DocumentSnapshot workerSnapshot = await FirebaseFirestore.instance
              .collection('workers')
              .doc(userId)
              .get();

          DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
              .collection('customers')
              .doc(userId)
              .get();

          if (workerSnapshot.exists) {
            setState(() {
              personality = 'Worker';
            });
          } else if (customerSnapshot.exists) {
            setState(() {
              personality = 'Customer';
            });
          } else {
            print('User document not found for user ID: $userId');
          }
        } catch (e) {
          print('Error retrieving personality: $e');
        }
      } else {
        print('User ID not found in SharedPreferences');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JEAS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Colors.lightBlue,
          secondary: Colors.lightBlue,
          error: Colors.red,
          background: Colors.white,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onError: Colors.white,
          onBackground: Colors.black,
          onSurface: Colors.black,
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            if (personality == 'Worker') {
              return const WorkerHome();
            } else if (personality == 'Customer') {
              return const CustomerHome();
            } else {
              return const SplashScreen();
            }
          }
          return const SplashScreen();
        },
      ),
    );
  }
}
