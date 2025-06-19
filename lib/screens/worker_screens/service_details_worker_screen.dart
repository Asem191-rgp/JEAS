import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jeas/screens/chat_screen/chat_page.dart';
import 'package:jeas/screens/customer_screens/customer_home_spectate.dart';
import 'package:jeas/screens/map_screen/map_page.dart';
import 'database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ServiceDetailsWorkerScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('customers');
  final CollectionReference workers =
      FirebaseFirestore.instance.collection('workers');
  final CollectionReference requests =
      FirebaseFirestore.instance.collection('requests');

  ServiceDetailsWorkerScreen({super.key, required this.data});

  @override
  State<ServiceDetailsWorkerScreen> createState() =>
      _ServiceDetailsWorkerScreenState();
}

class _ServiceDetailsWorkerScreenState
    extends State<ServiceDetailsWorkerScreen> {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('workers');
  Timer? _locationTimer;
  late String status;
  late String location = "";
  late String serviceType = "Repairs";
  late String category = "Electricity";
  bool directions = false;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    status = widget.data['status'];
    location = widget.data['location'];
    category = widget.data['serviceCategory'];
    _fetchAllImages();
  }

  @override
  dispose() {
    super.dispose();
    if (_locationTimer != null) {
      print("location timer stopped");
      _locationTimer!.cancel();
    }
  }

  Future<void> _fetchAllImages() async {
    try {
      final ListResult result = await FirebaseStorage.instance
          .ref('requests/${widget.data['uid']}')
          .listAll();
      final List<String> urls =
          await Future.wait(result.items.map((Reference ref) async {
        final String url = await ref.getDownloadURL();
        return url;
      }).toList());

      setState(() {
        imageUrls = urls;
      });
    } catch (e) {
      print('Error fetching images: $e');
    }
  }

  Future<Map<String, dynamic>> getRequesterInfo(String requesterUid) async {
    DocumentSnapshot doc = await widget.users.doc(requesterUid).get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data['title']),
        backgroundColor: _getColorFromStatus(status),
      ),
      body: StreamBuilder(
        stream: widget.requests.doc(widget.data['uid']).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          bool show = widget.data['status'] == "Accepted";
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // Loading indicator
            );
          }

          Map<String, dynamic> data = widget.data;

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context);
            });
          } else {
            data = snapshot.data!.data() as Map<String, dynamic>;
            if (data['workerUID'] != null &&
                FirebaseAuth.instance.currentUser!.uid != data['workerUID']) {
              Navigator.of(context).pop();
            }
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                GestureDetector(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    height: 170,
                    width: 100,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                        color: _getColorFromStatus(data['status']),
                        borderRadius: BorderRadius.circular(15)),
                    child: FutureBuilder(
                      future: getRequesterInfo(data['requesterUID']),
                      builder: (context,
                          AsyncSnapshot<Map<String, dynamic>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          Map<String, dynamic>? requesterData = snapshot.data;
                          return ListView(
                            children: [
                              const Text(
                                "Requester Name",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                              Text(
                                '${requesterData?['name']}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Status: ${data['status']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Requested at: ${data['created-at'].toDate()}',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Center(
                                child: Text(
                                  'Press to Show Profile',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color.fromARGB(255, 95, 95, 95),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpectateCustomerProfile(
                          id: widget.data["requesterUID"],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Description:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  height: 150,
                  width: 100,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(15)),
                  child: SingleChildScrollView(
                    child: Text(
                      '${data['description']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Text(
                  "Photos:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                photos(),
                const SizedBox(
                  height: 7,
                ),
                if (data['status'] == 'Pending')
                  Container(
                    width: 70,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadius.circular(70)),
                    child: MaterialButton(
                      onPressed: () async {
                        _locationTimer = Timer.periodic(
                            const Duration(seconds: 20), (timer) async {
                          print("getting location after accept***");
                          final currentPosition =
                              await Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high);
                          double lat = currentPosition.latitude;
                          double lon = currentPosition.longitude;
                          try {
                            await userCollection
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              "latitude": lat,
                              "longitude": lon,
                            });
                          } catch (e) {
                            print("Error getting latitude and longitude: $e");
                          }
                        });
                        setState(() {
                          show = true;
                          status = 'Accepted';
                        });
                        DatabaseService(uid: userId).acceptRequestService(
                            widget.data['uid'], widget.data['requesterUID']);
                      },
                      child: const Text(
                        'Accept Request',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                if (data['status'] == 'Accepted' &&
                    FirebaseAuth.instance.currentUser!.uid == data['workerUID'])
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () async {
                            DocumentSnapshot documentSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('workers')
                                    .doc(userId)
                                    .get();
                            setState(() {
                              _locationTimer!.cancel();
                            });
                            _showRateAndCommentDialog(
                                context, documentSnapshot['name']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            'Complete Service',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Flexible(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () async {
                            DatabaseService(uid: userId)
                                .cancelRequestService(widget.data['uid']);
                            setState(() {
                              if (_locationTimer != null) {
                                _locationTimer!.cancel();
                              }
                              show = false;
                              status = "Pending";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Cancel Service',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                const SizedBox(height: 16),
                Container(
                  color: _getColorFromStatus(data['status']),
                  child: ListTile(
                    leading: const Icon(
                      Icons.my_location,
                      color: Color.fromARGB(255, 100, 100, 100),
                    ),
                    title: Text(
                      location,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  color: _getColorFromStatus(data['status']),
                  child: ListTile(
                    leading: const Icon(
                      Icons.work,
                      color: Color.fromARGB(255, 100, 100, 100),
                    ),
                    title: Text(
                      category,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.data["status"] != "Completed")
                  FutureBuilder(
                    future: getRequesterInfo(data['requesterUID']),
                    builder: (context,
                        AsyncSnapshot<Map<String, dynamic>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        Map<String, dynamic>? requesterData = snapshot.data;

                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: MaterialButton(
                                onPressed: () {
                                  _makePhoneCall(
                                      requesterData?['phone_number'] ?? '');
                                },
                                child: const Text(
                                  'Call Requester',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            if (show == true || data["status"] == "Accepted")
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: MaterialButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapPage(
                                            requestId: widget.data["uid"]),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Go to Customer',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(
                              height: 15,
                            ),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(30)),
                                child: MaterialButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          receiverUserName:
                                              requesterData?['name'],
                                          receiverUserID: requesterData?['uid'],
                                          senderPersonality: 'workers',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Chat with Customer",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getColorFromStatus(String status) {
    switch (status) {
      case 'Pending':
        return Colors.red;
      case 'Accepted':
        return Colors.green;
      case 'Completed':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  void _showRateAndCommentDialog(BuildContext context, String name) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double rating = 0.0;
        return AlertDialog(
          title: const Text('Rate and Comment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 40,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (_rating) {
                    rating = _rating;
                  },
                ),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(labelText: 'Comment'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.isNotEmpty &&
                    rating >= 0.0 &&
                    rating <= 5.0) {
                  DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                      .finishRequestService(
                          widget.data['uid'], widget.data['requesterUID']);
                  setState(() {
                    status = "Finishing";
                  });
                  DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                      .addFeedback(name, widget.data['requesterUID'], rating,
                          commentController.text);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please enter a comment and rate between 0.0 and 5.0'),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget photos() {
    return imageUrls.isEmpty
        ? const Text("NO Photos")
        : SizedBox(
            height: MediaQuery.of(context).size.height - 430,
            child: Column(
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
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                child: Image.network(
                                  imageUrls[index],
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          height: 300,
                          width: 300,
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
