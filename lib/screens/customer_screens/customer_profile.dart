// ignore_for_file: avoid_print, unused_field, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeas/features/Cubits/profile_cubit.dart';
import 'package:jeas/features/user_image_picker.dart';
import 'dart:io';
import 'package:jeas/screens/common_screens/grid_image_picker.dart';
import '../common_screens/back_image.dart';

class CustomerProfile extends StatelessWidget {
  const CustomerProfile({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: const Customer(),
    );
  }
}

class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  State<Customer> createState() => CustomerProfileState();
}

class CustomerProfileState extends State<Customer> {
  File? _selectedImage;
  File? _selected;
  String job = '', date = "";
  String userId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController desc = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final userInfo = ProfileCubit.get(context);
    if (userId.isNotEmpty) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        userInfo.addName(snapshot['name']);
        userInfo.addBirthday(snapshot['birthday']);
        userInfo.addDesc(snapshot['description']);
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
          FirebaseFirestore.instance.collection('customers').doc(userId);
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        await userRef.update({
          'description': desc.text,
        });

        print("Description added to Firestore");
      } else {
        print("User document doesn't exist");
      }
    } catch (e) {
      print("Failed to add description: $e");
    }
    final userInfo = ProfileCubit.get(context);
    userInfo.addDesc(desc.text);
  }

  Future<DocumentSnapshot> _loadUserData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('customers')
        .doc(userId)
        .get();
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Stack(
          children: [
            const BackImage(),
            FutureBuilder<DocumentSnapshot>(
              future: _loadUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final userData = snapshot.data!;
                    final userName = userData['name'] as String?;
                    final birthDay = userData['birthday'] as String?;
                    List<dynamic> ratesDynamic = userData['rates'] ?? [];
                    List<double> rates = ratesDynamic.cast<double>();
                    double rate = 0.0;
                    if (rates.isNotEmpty) {
                      rate = rates.reduce((value, element) => value + element) /
                          rates.length;
                    }
                    List<dynamic> comments = userData['comments'] ?? [];
                    return ListView(
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  height: 350,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(30),
                                    ),
                                    border: Border.all(
                                        color: Colors.lightBlue, width: 3),
                                  ),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        alignment: Alignment.centerRight,
                                        height: 40,
                                        child: Text(
                                          "Rate : ${rate.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        userName ?? 'Loading...',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "TiffanyHeavy"),
                                      ),
                                      const SizedBox(height: 30),
                                      Row(
                                        children: [
                                          const Text(
                                            "Date of Birth : ",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            birthDay!,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.green),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: 100,
                                          width: 250,
                                          child: BlocBuilder<ProfileCubit,
                                              ProfileCubitState>(
                                            builder: (context, state) {
                                              return GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                          'Add New Description',
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Expanded(
                                                              child: SizedBox(
                                                                child:
                                                                    TextField(
                                                                  controller:
                                                                      desc,
                                                                  maxLines:
                                                                      null,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    hintText:
                                                                        "add the new description",
                                                                    hintStyle: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .lightBlue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              17)),
                                                              child:
                                                                  MaterialButton(
                                                                onPressed: () {
                                                                  changeDesc();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Update",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  state.description ??
                                                      'Tap to add text',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              );
                                            },
                                          )),
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
                                  height:
                                      MediaQuery.of(context).size.height - 430,
                                  child: TabBarView(
                                    children: [
                                      GridImagePicker(
                                        onPickImage: (File pick) {
                                          _selected = pick;
                                        },
                                      ),
                                      ListView.builder(
                                        itemCount: comments.length,
                                        itemBuilder: (context, index) {
                                          Color tileColor = index.isEven
                                              ? Colors.blue[50]!
                                              : Colors.blue[100]!;
                                          return Card(
                                            color: tileColor,
                                            child: ListTile(
                                              title: Text(getCommentInfo(
                                                  comments[index])[1]),
                                              subtitle: Text(
                                                  "- ${getCommentInfo(comments[index])[0]}"),
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
                    );
                  }
                }
              },
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
