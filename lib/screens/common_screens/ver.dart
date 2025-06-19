// ignore_for_file: use_build_context_synchronously, avoid_print, no_logic_in_create_state, unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jeas/screens/common_screens/login.dart';
import 'package:jeas/screens/common_screens/signup.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:async';

class VerCode extends StatefulWidget {
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController phone;
  final String person;

  const VerCode(this.email, this.password, this.phone, this.person,
      {super.key});

  @override
  State<VerCode> createState() => _VerCodeState();
}

class _VerCodeState extends State<VerCode> {
  late TextEditingController email;
  late TextEditingController password;
  late TextEditingController phone;
  late String _verificationId;
  late String person;
  String imgUrl = "";
  Timer? time;
  bool _isLoading = false;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getImageUrl();
    email = widget.email;
    password = widget.password;
    phone = widget.phone;
    _verificationId = "";
    person = widget.person;
    _verify();
    time = Timer.periodic(const Duration(seconds: 1), (timer) {
      user!.reload();
    });
  }

  @override
  void dispose() {
    time?.cancel();
    super.dispose();
  }

  Future<void> getImageUrl() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('ID.jpg');
      final url = await ref.getDownloadURL();
      setState(() {
        imgUrl = url;
      });
    } catch (e) {
      print('Error getting image URL: $e');
    }
  }

  Future<void> _verify() async {
    await _sendVerificationEmail();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      }
    } catch (error) {
      print("Error sending verification email: $error");
    }
  }

  Future<void> _checkVerification() async {
    setState(() {
      _isLoading = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          time!.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Please check your email for the verification link .",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
      }
    } catch (error) {
      print("Error verifying email and phone number: $error");
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'ERROR',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          'Verification',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              const Column(
                children: [
                  Text(
                    "You have received a verification link.\nPlease check your E-mail",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Open Your E-mail and Click on the link then click Verify button",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Image.asset(
                "assets/images/verpic.png",
                height: 300,
                fit: BoxFit.contain,
              ),
              Container(
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(17)),
                child: MaterialButton(
                  onPressed: _isLoading ? null : _checkVerification,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Verify",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Didn't receive the link?",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  TextButton(
                    onPressed: _sendVerificationEmail,
                    child: const Text(
                      "Resend link",
                      style: TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Can't access this account?",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email.text,
                          password: password.text,
                        );

                        User? currentUser = FirebaseAuth.instance.currentUser;

                        if (currentUser != null) {
                          time!.cancel();
                          try {
                            try {
                              await FirebaseFirestore.instance
                                  .collection(person)
                                  .doc(currentUser.uid)
                                  .delete();
                            } catch (error) {
                              print("Failed to delete user and data: $error");
                              _showErrorDialog(
                                  "Failed to delete user and data");
                            }

                            await currentUser.delete();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ),
                            );
                          } catch (error) {
                            print("Failed to delete user and data: $error");
                            _showErrorDialog("Failed to delete user and data");
                          }
                        } else {
                          print("Current user is null");
                          _showErrorDialog("Current user is null");
                        }
                      } on FirebaseAuthException catch (error) {
                        print("Error deleting account: $error");
                        _showErrorDialog("Error deleting account: $error");
                      }
                    },
                    child: const Text(
                      "Change Account",
                      style: TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
