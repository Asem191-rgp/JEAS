// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:jeas/screens/common_screens/login.dart';
import '../common_screens/back_image.dart';

class SpectateCustomerProfile extends StatefulWidget {
  final String id;
  const SpectateCustomerProfile({required this.id, super.key});

  @override
  State<SpectateCustomerProfile> createState() =>
      _SpectateCustomerProfileState();
}

class _SpectateCustomerProfileState extends State<SpectateCustomerProfile> {
  String _userName = '';
  String _description = 'Tap to add text';
  String imgUrl = "";
  String? userId;
  List<String> imageUrls = [];
  TextEditingController description = TextEditingController();
  double _rate = 0.0;
  List<dynamic> _comments = [];

  @override
  void initState() {
    super.initState();
    userId = widget.id;
    print("User ID is : $userId");
    _loadUserName();
    _getImagesFromFirebase();
    getImageUrl();
  }

  Future<void> _loadUserName() async {
    if (userId!.isNotEmpty) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          _userName = snapshot['name'] ?? '';
          _description = snapshot['description'] ?? '';
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

  Future<void> _getImagesFromFirebase() async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child(userId!).child("/grid_images/");

      final ListResult result = await storageRef.listAll();

      for (final Reference ref in result.items) {
        final url = await ref.getDownloadURL();
        setState(() {
          imageUrls.add(url);
        });
      }
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<void> getImageUrl() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(userId!)
          .child('ProfileImage.jpg');
      final url = await ref.getDownloadURL();
      setState(() {
        imgUrl = url;
      });
    } catch (e) {
      print('Error getting image URL: $e');
      final ref = FirebaseStorage.instance.ref().child('logo.jpeg');
      final url = await ref.getDownloadURL();
      setState(() {
        imgUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            const Image(
              image: AssetImage('assets/images/logo.jpeg'),
              height: 100,
            ),
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut().then((value) =>
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (route) => false));
              },
              icon: const Icon(Icons.exit_to_app),
              tooltip: "Log Out",
            ),
          ],
        ),
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
                                _userName.isNotEmpty ? _userName : 'Loading...',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "TiffanyHeavy"),
                              ),
                              const SizedBox(height: 10),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                height: 100,
                                width: 250,
                                child: Text(
                                  _description,
                                  style: const TextStyle(fontSize: 12),
                                ),
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
                              Column(
                                children: [
                                  Expanded(
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5,
                                      ),
                                      itemCount: imageUrls.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Image.network(
                                          imageUrls[index],
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.lightBlue, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage:
                            imgUrl.isNotEmpty ? NetworkImage(imgUrl) : null,
                      ),
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

  List<String> getCommentInfo(String comment) {
    return comment.split("::");
  }
}
