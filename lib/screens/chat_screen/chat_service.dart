import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeas/screens/chat_screen/message.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverUserID, String message,
      String senderPersonality, String imgUrl) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final dynamic data =
        await _fireStore.collection(senderPersonality).doc(currentUserId).get();
    final String currentUserName = data['name'];
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      senderName: currentUserName,
      receiverId: receiverUserID,
      message: message,
      imgUrl: imgUrl,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, receiverUserID];
    ids.sort();
    String chatRoomId = ids.join('_');

    if (imgUrl.isNotEmpty) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          FirebaseStorage.instance.ref().child(chatRoomId).child(fileName);
      await ref.putFile(File(imgUrl));
      newMessage.imgUrl = await ref.getDownloadURL();
    }

    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    List<dynamic> messages = data['messages'];
    if (!messages.contains(receiverUserID)) {
      await _fireStore.collection(senderPersonality).doc(currentUserId).update({
        "messages": FieldValue.arrayUnion([receiverUserID]),
      });

      await _fireStore
          .collection(senderPersonality.toLowerCase() == 'customers'
              ? 'workers'
              : 'customers')
          .doc(receiverUserID)
          .update({
        "messages": FieldValue.arrayUnion([currentUserId]),
      });
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .snapshots();
  }
}
