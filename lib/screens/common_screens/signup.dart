// ignore_for_file: avoid_print, use_build_context_synchronously, unused_field
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeas/features/birthday_dropdown_signup.dart';
import 'package:jeas/features/drop_down.dart';
import 'package:jeas/features/email_field.dart';
import 'package:jeas/features/name_field.dart';
import 'package:jeas/features/password_field.dart';
import 'package:jeas/features/phonenumber_field.dart';
import 'package:jeas/screens/common_screens/login.dart';
import 'package:jeas/screens/common_screens/ver.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jeas/terms_and_conditions.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fname = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController date = TextEditingController();
  final TextEditingController skill = TextEditingController();
  File? _pickedImageFile;
  bool _isLoading = false;
  bool checked = false;
  bool choosed = false;
  File? _selectedImage;
  String imgUrl = "";
  String personality = "Customer";

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
        _showErrorDialog(
            "you didnt give us the access th your location so you cant login we are sorry :(");
        Navigator.pop(context);
        return Future.error('Location services are disabled.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog(
          "you didnt give us the access th your location so you cant login we are sorry :(");
      Navigator.pop(context);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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

  void updatePersonality(String personalityValue, String skillValue) {
    setState(() {
      personality = personalityValue;
      skill.text = skillValue;
    });
  }

  Future<void> _pickImage(ImageSource pick) async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: pick,
        imageQuality: 100,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        _selectedImage = File(pickedImage.path);
        choosed = true;
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _choose() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> addUserToFirebase() async {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    final pos = await getLocation();
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.requestPermission();
    final token = await firebaseMessaging.getToken();
    try {
      final userData = {
        'uid': userUid,
        'name': "${_fname.text[0].toUpperCase()}${_fname.text.substring(1)} ",
        'email': _emailController.text,
        'phone_number': _phone.text,
        'description': 'Add Description here',
        'birthday': date.text,
        'requests': [],
        'messages': [],
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'status': 'pending',
        'fcmToken': token,
        'rates': [],
        'comments': [],
        'CV_Link': ""
      };

      if (personality == "Worker") {
        userData.addAll({
          'skills': skill.text,
          'personality': personality,
        });
        await FirebaseFirestore.instance
            .collection('workers')
            .doc(userUid)
            .set(userData);
      } else {
        userData.addAll({
          'personality': personality,
        });
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(userUid)
            .set(userData);
      }

      print("User Added to Firestore: $userData");
    } catch (e) {
      print("Failed to add user: $e");
      _showErrorDialog("Failed to add user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/back.png"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image(
                        image: AssetImage('assets/images/logo.jpeg'),
                        height: 80,
                      ),
                    ],
                  ),
                ),
                const Center(
                  child: Text(
                    "Create your Account",
                    style: TextStyle(
                      fontFamily: 'TiffanyHeavy',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    "Sign up And Create Your Account Here",
                    style: TextStyle(
                      fontFamily: 'TiffanyHeavy',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 8,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      NameField("Name (From 3 parts as in your ID Card)",
                          _fname, "Enter your Name from 3 parts"),
                      EmailField("E-mail Address", _emailController,
                          "Enter your Email"),
                      PhoneNumberField("Phone Number", _phone, "07xxxxxxxx"),
                      PasswordField("Create Your Password", _passwordController,
                          "8 Characters with capital letter"),
                      DateField(dateController: date),
                      const Text(
                        "Please Enter Your ID Card Image and make sure that all your info are the same in the ID ",
                        style: TextStyle(
                          fontFamily: 'TiffanyHeavy',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      InkWell(
                        onTap: _choose,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            width: 250,
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: _selectedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_selectedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _selectedImage == null
                                ? const Center(
                                    child: Text(
                                      'No Image',
                                      style: TextStyle(color: Colors.lightBlue),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Enter Your Personality ",
                        style: TextStyle(
                          fontFamily: 'TiffanyHeavy',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      DropDownValue(
                        skill,
                        personality,
                        (newValue, val3) {
                          updatePersonality(newValue, val3);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            value: checked,
                            onChanged: (bool? value) {
                              setState(() {
                                checked = value!;
                              });
                            },
                          ),
                          Row(
                            children: [
                              const Text(
                                "I Agree with the",
                                style: TextStyle(
                                  fontFamily: 'TiffanyHeavy',
                                  fontSize: 8,
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const TermsAndConditionsPage(),
                                        ));
                                  },
                                  child: const Text(
                                    "terms & conditions",
                                    style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontFamily: 'TiffanyHeavy',
                                      fontSize: 10,
                                    ),
                                  ))
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.lightBlue,
                  ),
                  child: MaterialButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            {
                              if (choosed) {
                                setState(() {
                                  _isLoading = true;
                                });
                                if (_formKey.currentState!.validate() &&
                                    checked) {
                                  try {
                                    final credentials = await FirebaseAuth
                                        .instance
                                        .createUserWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                                    print(
                                        "_______________login credintial ID is : ${credentials.user!.uid}");
                                    await addUserToFirebase();
                                    // Upload image to Firebase Storage
                                    final storageRef = FirebaseStorage.instance
                                        .ref()
                                        .child(credentials.user!.uid)
                                        .child('ID.jpg');
                                    try {
                                      await storageRef.putFile(
                                          _selectedImage!,
                                          SettableMetadata(
                                            contentType: "image/jpg",
                                          ));
                                    } catch (e) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      return _showErrorDialog(
                                          "Please Add Image for Your ID card");
                                    }
                                    // Get image URL
                                    final imageUrl =
                                        await storageRef.getDownloadURL();
                                    print(
                                        "+++++++++++++++the URL of the image is : $imageUrl ");

                                    // Navigate to verification screen
                                    if (personality == "Worker") {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VerCode(
                                              _emailController,
                                              _passwordController,
                                              _phone,
                                              "workers"),
                                        ),
                                      );
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VerCode(
                                              _emailController,
                                              _passwordController,
                                              _phone,
                                              "customers"),
                                        ),
                                      );
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'weak-password') {
                                      _showErrorDialog(
                                          "Your password is weak. Please make it more complex.");
                                    } else if (e.code == "invalid-email") {
                                      _showErrorDialog(
                                          "The email entered is not valid. Please try again.");
                                    } else if (e.code ==
                                        "email-already-in-use") {
                                      _showErrorDialog(
                                          "This email is already in use!");
                                    }
                                  }
                                } else {
                                  _showErrorDialog(
                                      "Please ensure all fields are filled correctly and agree with the terms & conditions .");
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                              } else {
                                _showErrorDialog("PLease Choose Picture");
                              }
                            }
                          },
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontFamily: 'TiffanyHeavy',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have account?",
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
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign in here",
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
        ],
      ),
    );
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
}
