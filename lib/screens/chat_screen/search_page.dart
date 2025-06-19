import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jeas/screens/worker_screens/worker_spectate_profile.dart';

class UserInfo {
  final String id;
  final String name;
  final String imageUrl;

  UserInfo({required this.id, required this.name, required this.imageUrl});
}

class UserSearchPage extends StatefulWidget {
  final String personality;
  const UserSearchPage({super.key, required this.personality});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UserInfo> _searchResult = [];
  late String person;

  @override
  void initState() {
    person = widget.personality;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search Users...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _searchUsers(value);
          },
        ),
      ),
      body: _buildSearchResults(),
    );
  }

  void _searchUsers(String query) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (query.isNotEmpty) {
      snapshot = await FirebaseFirestore.instance
          .collection('workers')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .get();

      List<UserInfo> searchResults = [];

      for (final doc in snapshot.docs) {
        final imgUrl = await _getRequesterPhotoUrl(doc['uid']);
        final userInfo = UserInfo(
          id: doc.id,
          name: doc['name'],
          imageUrl: imgUrl ?? '',
        );
        searchResults.add(userInfo);
      }

      setState(() {
        _searchResult = searchResults;
      });
    } else {
      setState(() {
        _searchResult = [];
      });
    }
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResult.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(_searchResult[index].imageUrl),
          ),
          title: Text(_searchResult[index].name),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SpectateWorkerProfile(workerUID: _searchResult[index].id),
              ),
            );
          },
        );
      },
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
      try {
        Reference ref = FirebaseStorage.instance.ref().child('logo.jpeg');
        String url = await ref.getDownloadURL();
        return url;
      } catch (e) {
        print('Error retrieving photo: $e');
        return null;
      }
    }
  }
}
