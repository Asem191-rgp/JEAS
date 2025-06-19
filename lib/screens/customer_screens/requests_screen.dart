// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'request_service_screen.dart';
import 'service_details_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RequestsScreen extends StatelessWidget {
  final CollectionReference serviceRequests =
      FirebaseFirestore.instance.collection('requests');

  RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Requested Services',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: serviceRequests
            .where('requesterUID',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return snapshot.data!.docs.isEmpty
              ? const Center(
                  child: Text('No requests'),
                )
              : ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;
                    data['requestId'] = snapshot.data!.docs[index].id;

                    Color tileColor =
                        index.isEven ? Colors.green[50]! : Colors.green[100]!;
                    return Dismissible(
                      key: Key(snapshot.data!.docs[index].id),
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerStart,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        String requestId = snapshot.data!.docs[index].id;
                        Map<String, dynamic> requestData =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;

                        serviceRequests.doc(requestId).delete().then((value) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(requestData['requesterUID'])
                              .collection('requests')
                              .doc(requestId)
                              .delete();
                        });
                      },
                      child: Card(
                        color: tileColor,
                        child: ListTile(
                          title: Text(data['title']),
                          subtitle: Text(data['description']),
                          trailing: FutureBuilder<String?>(
                            future: _getRequesterPhotoUrl(data['requesterUID']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasData) {
                                return CircleAvatar(
                                  backgroundImage: NetworkImage(snapshot.data!),
                                );
                              } else {
                                return const Icon(Icons.person);
                              }
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceDetailsScreen(
                                  data: data,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ServiceRequestScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _getRequesterPhotoUrl(String? requesterUid) async {
    if (requesterUid == null) return null;

    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('$requesterUid/ProfileImage.jpg');
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error retrieving photo: $e');
      return null;
    }
  }
}
