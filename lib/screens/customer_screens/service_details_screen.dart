// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jeas/screens/chat_screen/chat_page.dart';
import 'package:jeas/screens/map_screen/map_page_customer_side.dart';
import 'package:jeas/screens/worker_screens/worker_spectate_profile.dart';
import 'database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final CollectionReference workers =
      FirebaseFirestore.instance.collection('workers');
  final CollectionReference requests =
      FirebaseFirestore.instance.collection('requests');

  ServiceDetailsScreen({super.key, required this.data});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  String status = "";
  final userUid = FirebaseAuth.instance.currentUser!.uid;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    status = widget.data['status'];
    _fetchAllImages();
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

  Future<Map<String, dynamic>> getWorkerInfo(String workerUid) async {
    DocumentSnapshot doc = await widget.workers.doc(workerUid).get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Could not launch phone call.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.data['uid'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          Map<String, dynamic> newData =
              snapshot.data!.data() as Map<String, dynamic>;

          print("newData: $newData");
          return Scaffold(
            appBar: AppBar(
              title: Text(newData['title']),
              backgroundColor: _getColorFromStatus(newData['status']),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    height: 150,
                    width: 270,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                        color: _getColorFromStatus(newData['status']),
                        borderRadius: BorderRadius.circular(15)),
                    child: ListView(
                      children: [
                        const Text(
                          "My Request",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${newData['status']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Requested at: ${newData['created-at'].toDate()}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "Description:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    height: 150,
                    width: 270,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                        color: Colors.lightBlue[100],
                        borderRadius: BorderRadius.circular(15)),
                    child: SingleChildScrollView(
                      child: Text(
                        '${newData['description']}',
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
                  if (newData['status'] == 'Pending' && userUid.isNotEmpty)
                    Center(
                      child: Container(
                        width: 220,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                            DatabaseService(uid: userUid)
                                .deleteRequestService(newData['uid']);
                          },
                          child: const Text(
                            'Delete Request',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  if (newData['status'] == 'Finishing')
                    ElevatedButton(
                      onPressed: () async {
                        DocumentSnapshot documentSnapshot =
                            await FirebaseFirestore.instance
                                .collection('customers')
                                .doc(userUid)
                                .get();
                        _showRateAndCommentDialog(context,
                            documentSnapshot['name'], newData['workerUID']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text(
                        'Rate and Comment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if ((newData['status'] == 'Accepted' ||
                          newData['status'] == 'Completed') &&
                      userUid.isNotEmpty)
                    FutureBuilder(
                      future: getWorkerInfo(newData['workerUID']),
                      builder: (context,
                          AsyncSnapshot<Map<String, dynamic>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          Map<String, dynamic>? workerData = snapshot.data;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                height: 270,
                                width: 270,
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                    color:
                                        _getColorFromStatus(newData['status']),
                                    borderRadius: BorderRadius.circular(15)),
                                child: ListView(
                                  children: [
                                    const Text(
                                      "Worker Info ",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Name:\n${workerData?['name']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if ((newData['status'] == 'Accepted') &&
                                        userUid.isNotEmpty)
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DistanceForCustomer(
                                                requestId: newData["uid"],
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.lightBlue,
                                        ),
                                        child: const Text(
                                          'See Where Worker Now',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _makePhoneCall(
                                            workerData?['phone_number']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.lightBlue,
                                      ),
                                      child: const Text(
                                        'Call Worker',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.lightBlue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SpectateWorkerProfile(
                                              workerUID: workerData?['uid'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Show Worker Profile",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.lightBlue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                              receiverUserName:
                                                  workerData?['name'],
                                              receiverUserID:
                                                  workerData?['uid'],
                                              senderPersonality: 'customers',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "Chat with Worker",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: _getColorFromStatus(newData['status']),
                    child: ListTile(
                      leading: const Icon(
                        Icons.my_location,
                        color: Color.fromARGB(255, 100, 100, 100),
                      ),
                      title: Text(
                        newData['location'],
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
                    color: _getColorFromStatus(newData['status']),
                    child: ListTile(
                      leading: const Icon(
                        Icons.work,
                        color: Color.fromARGB(255, 100, 100, 100),
                      ),
                      title: Text(
                        newData['serviceCategory'],
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  void _showRateAndCommentDialog(
      BuildContext context, String name, String workerId) {
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
                      .completeRequestService(widget.data['uid']);
                  setState(() {
                    status = "Completed";
                  });
                  print(
                      "widget.data['workerUID']: ${widget.data['workerUID']}");
                  DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                      .addFeedback(
                          name, workerId, rating, commentController.text);
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
