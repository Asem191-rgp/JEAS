import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jeas/screens/chat_screen/chat_page.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatsPage extends StatefulWidget {
  final String personality;
  const ChatsPage({super.key, required this.personality});

  @override
  State<ChatsPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatsPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      backgroundColor: Colors.grey[300],
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(widget.personality.toLowerCase() == 'customers'
                  ? 'workers'
                  : 'customers')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }

            return ListView(
              children: snapshot.data!.docs
                  .map<Widget>((doc) => _buildUserListItem(doc))
                  .toList(),
            );
          }),
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    List<dynamic> messages = data['messages'];
    if (data.isNotEmpty &&
        FirebaseAuth.instance.currentUser!.uid != data['uid'] &&
        data['status'] == 'activated' &&
        messages.contains(FirebaseAuth.instance.currentUser!.uid)) {
      Color tileColor = index.isEven ? Colors.blue[50]! : Colors.blue[100]!;
      index++;
      return Card(
        color: tileColor,
        child: ListTile(
          title: Text(data['name']),
          trailing: FutureBuilder<String?>(
            future: _getRequesterPhotoUrl(data['uid']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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
                builder: (context) => ChatPage(
                  receiverUserName: data['name'],
                  receiverUserID: data['uid'],
                  senderPersonality: widget.personality,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container();
    }
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
