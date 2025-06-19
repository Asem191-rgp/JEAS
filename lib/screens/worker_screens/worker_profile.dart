// ignore_for_file: avoid_print, unused_field, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeas/features/user_image_picker.dart';
import 'dart:io';
import 'package:jeas/screens/common_screens/grid_image_picker.dart';
import '../common_screens/back_image.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _selectedImage;
  File? _selected;
  String _userName = '';
  String _description = 'Tap to add text';
  String _job = '';
  String _date = '';
  double _rate = 0.0;
  List<dynamic> _comments = [];
  final userId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController description = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    if (userId.isNotEmpty) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('workers')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          _userName = snapshot['name'] ?? '';
          _description = snapshot['description'] ?? '';
          _job = snapshot['skills'] ?? '';
          _date = snapshot['birthday'] ?? '';
          List<dynamic> ratesDynamic = snapshot['rates'] ?? [];
          List<double> rates = ratesDynamic.cast<double>();
          double rate = 0.0;
          if (rates.isNotEmpty) {
            rate = rates.reduce((value, element) => value + element) /
                rates.length;
          }
          _rate = rate;
          _comments = snapshot['comments'] ?? [];
        });
      } else {
        print('User document not found for user ID: $userId');
      }
    } else {
      print('User ID not found in SharedPreferences');
    }
  }

  void changeDesc() async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('workers').doc(userId);
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        await userRef.update({
          'description': description.text,
        });

        print("Description added to Firestore");
      } else {
        print("User document doesn't exist");
      }
    } catch (e) {
      print("Failed to add description: $e");
    }
    setState(() {
      _description = description.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Stack(
          children: [
            const BackImage(),
            ListView(
              children: [
                const SizedBox(
                  height: 100,
                ),
                Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 100,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          height: 500,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(30),
                            ),
                            border:
                                Border.all(color: Colors.lightBlue, width: 3),
                          ),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.centerRight,
                                height: 40,
                                child: Text(
                                  "Rate : ${_rate.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _userName.isNotEmpty
                                    ? _userName
                                    : 'Cant Find Name',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "TiffanyHeavy"),
                              ),
                              const SizedBox(height: 10),
                              const Row(
                                children: [
                                  Text(
                                    "Jobs/Crafts : ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                _job,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.green),
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "Date of Birth : ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _date,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.green),
                                  ),
                                ],
                              ),
                              const CVLinkWidget(),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                height: 100,
                                width: 250,
                                child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                              'Add New Description',
                                              textAlign: TextAlign.center,
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Expanded(
                                                  child: SizedBox(
                                                    child: TextField(
                                                      controller: description,
                                                      maxLines: null,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText:
                                                            "add the new description",
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                MaterialButton(
                                                  onPressed: () {
                                                    changeDesc();
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    "Update",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      _description,
                                      style: const TextStyle(fontSize: 12),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.grey,
                          height: 10,
                        ),
                        Container(
                          color: Colors.white,
                          child: const TabBar(
                            tabs: [
                              Tab(
                                child: Text(
                                  "Photos",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  "Comments",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height - 430,
                          child: TabBarView(
                            children: [
                              GridImagePicker(
                                onPickImage: (File pick) {
                                  _selected = pick;
                                },
                              ),
                              ListView.builder(
                                itemCount: _comments.length,
                                itemBuilder: (context, index) {
                                  Color tileColor = index.isEven
                                      ? Colors.blue[50]!
                                      : Colors.blue[100]!;
                                  return Card(
                                    color: tileColor,
                                    child: ListTile(
                                      title: Text(
                                          getCommentInfo(_comments[index])[1]),
                                      subtitle: Text(
                                          "- ${getCommentInfo(_comments[index])[0]}"),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    UserImagePicker(
                      onPickImage: ((pickedImage) {
                        _selectedImage = pickedImage;
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> getCommentInfo(String commentText) {
    return commentText.split("::");
  }
}

class CVLinkWidget extends StatefulWidget {
  const CVLinkWidget({Key? key});

  @override
  State<CVLinkWidget> createState() => _CVLinkWidgetState();
}

class _CVLinkWidgetState extends State<CVLinkWidget> {
  final TextEditingController _cvLinkController = TextEditingController();
  String _cvLink = "https://example.com";
  bool _isEditing = false;
  bool _saved = false;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchCVLink();
    _cvLinkController.text = _cvLink;
  }

  Future<void> _fetchCVLink() async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('workers').doc(userId);
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        setState(() {
          _cvLink = userDoc.get('CV_Link') ?? _cvLink;
          _cvLinkController.text = _cvLink;
        });
      } else {
        print("User document doesn't exist");
      }
    } catch (e) {
      print("Failed to fetch CV link: $e");
    }
  }

  @override
  void dispose() {
    _cvLinkController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      _saved = false;
    });
  }

  void _saveCVLink() async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('workers').doc(userId);
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        await userRef.update({
          'CV_Link': _cvLinkController.text,
        });

        print("CV link added to Firestore");
      } else {
        print("User document doesn't exist");
      }
    } catch (e) {
      print("Failed to add CV link: $e");
    }
    setState(() {
      _cvLink = _cvLinkController.text;
      _isEditing = false;
      _saved = true;
    });
  }

  void _launchCVLink() async {
    String url = _cvLinkController.text;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "CV Link: ",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: _isEditing
              ? TextField(
                  controller: _cvLinkController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your CV link here',
                  ),
                )
              : GestureDetector(
                  onTap: _launchCVLink,
                  child: _saved
                      ? Text(
                          _cvLink.length > 30
                              ? "${_cvLink.substring(0, 30)}..."
                              : _cvLink,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        )
                      : Text(
                          "${_cvLink.substring(0, 19)}...",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                ),
        ),
        IconButton(
          icon: _isEditing ? const Icon(Icons.save) : const Icon(Icons.edit),
          onPressed: _isEditing ? _saveCVLink : _toggleEdit,
        ),
      ],
    );
  }
}
