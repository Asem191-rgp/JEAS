// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:jeas/features/login_password_field.dart';
import 'package:jeas/screens/common_screens/signup.dart';
import 'package:jeas/screens/common_screens/ver.dart';
import '../../features/login_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jeas/screens/worker_screens/worker_home.dart';
import '../customer_screens/customer_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  String personalit = '';
  bool _is_loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const Image(
          image: AssetImage('assets/images/logo.jpeg'),
          height: 80,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                "Hello, Guest!\nWelcome to JEAS",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "Before Continue, Please Sign in First.\n(Scroll Page Down)",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/worker.png",
                      height: 350,
                      fit: BoxFit.contain,
                      alignment: Alignment.center),
                ],
              ),
              LoginTextField("Email", email, "Enter E-mail", false),
              const SizedBox(height: 20),
              LoginPasswordTextField(
                  "Password", password, "Enter Password", true),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email.text);
                    _showErrorDialog(
                        "We have sent a password reset link to your email. Please check your inbox if you didn't receive message make sure that your account is exist.");
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(17)),
                width: double.infinity,
                height: 50,
                child: MaterialButton(
                  onPressed: _is_loading ? null : _signIn,
                  child: _is_loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "SIGN IN",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't Have Account?",
                    style: TextStyle(
                      fontFamily: 'TiffanyHeavy',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUp()),
                      );
                    },
                    child: const Text(
                      "Sign Up here",
                      style: TextStyle(
                        fontFamily: 'TiffanyHeavy',
                        fontSize: 10,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  initState() {
    getLocation();
    super.initState();
  }

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
        Navigator.pop(context);
        return Future.error('Location services are disabled.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Navigator.pop(context);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _signIn() async {
    setState(() {
      _is_loading = true;
    });
    if (FirebaseAuth.instance.currentUser != null) {
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        if (personalit == "Worker") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerCode(email, password, phone, "workers"),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VerCode(email, password, phone, "customers"),
            ),
          );
        }
      }
    }
    try {
      final credentials =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      if (!mounted) return;
      print("_______________login credintial ID is : ${credentials.user!.uid}");
      SharedPreferences credit = await SharedPreferences.getInstance();
      await credit.setString('credential', credentials.user!.uid);

      // Check if user exists in the "workers" collection
      final workerDoc = await FirebaseFirestore.instance
          .collection('workers')
          .doc(credentials.user!.uid)
          .get();

      final customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(credentials.user!.uid)
          .get();

      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      firebaseMessaging.requestPermission();
      final token = await firebaseMessaging.getToken();

      if (!mounted) return;
      if (workerDoc.exists) {
        final doc = FirebaseFirestore.instance
            .collection('workers')
            .doc(credentials.user!.uid);
        await doc.update({
          'fcmToken': token,
        });
        if (workerDoc['status'] != 'activated') {
          _showErrorDialog(getAccountStatusMessage(workerDoc['status']));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const WorkerHome()));
        }
      } else if (customerDoc.exists) {
        final doc = FirebaseFirestore.instance
            .collection('customers')
            .doc(credentials.user!.uid);
        await doc.update({
          'fcmToken': token,
        });
        if (customerDoc['status'] != 'activated') {
          _showErrorDialog(getAccountStatusMessage(customerDoc['status']));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const CustomerHome()));
        }
      } else {
        _showErrorDialog("User NOT Found");
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'user-not-found') {
        _showErrorDialog('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showErrorDialog('Wrong password provided for that user.');
      } else if (e.code == "invalid-credential") {
        _showErrorDialog('Error: Invalid Email or Password');
      } else {
        _showErrorDialog('Error: ${e.message}');
      }
    }
    setState(() {
      _is_loading = false;
    });
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'WARNING',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  String getAccountStatusMessage(String status) {
    if (status == 'pending') {
      return "Account status is pending. Wait for an admin to review your account.";
    } else if (status == 'deactivated') {
      return "Account status is deactivated. Contact support to review your account.";
    } else if (status == 'declined') {
      return "Account status is declined. Contact support to review your account.";
    }
    return 'activated';
  }
}
