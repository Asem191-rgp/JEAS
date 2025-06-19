import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeas/screens/chat_screen/chat_bubble.dart';
import 'package:jeas/screens/chat_screen/chat_service.dart';
import 'package:jeas/screens/chat_screen/my_text_field.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserID;
  final String senderPersonality;
  const ChatPage({
    super.key,
    required this.receiverUserName,
    required this.receiverUserID,
    required this.senderPersonality,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  String imgUrl = '';

  Future<void> _pickImage(ImageSource pick) async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: pick,
        imageQuality: 75,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        imgUrl = pickedImage.path;
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
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                  print('imgUrl: $imgUrl');
                  sendMessage();
                  setState(() {
                    imgUrl = '';
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                  print('imgUrl: $imgUrl');
                  sendMessage();
                  setState(() {
                    imgUrl = '';
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty || imgUrl.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserID,
          _messageController.text, widget.senderPersonality, imgUrl);
      _messageController.clear();
      setState(() {
        imgUrl = '';
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            widget.receiverUserID, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }

          return ListView.builder(
            reverse: true,
            controller: _scrollController,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return _buildMessageItem(snapshot.data!.docs, index);
            },
          );
        });
  }

  Widget _buildMessageItem(List<dynamic> snapshots, int index) {
    Map<String, dynamic> data =
        snapshots.elementAt(index).data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    bool putName = true;
    if (index < snapshots.length - 1) {
      Map<String, dynamic> prevData =
          snapshots.elementAt(index + 1).data() as Map<String, dynamic>;
      if (prevData['senderId'] == data['senderId']) {
        putName = false;
      }
    }
    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          mainAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            putName ? Text(data['senderName']) : Container(),
            const SizedBox(height: 5),
            data['imgUrl'].isNotEmpty
                ? _buildPhoto(data['imgUrl'])
                : ChatBubble(message: data['message']),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: 'Enter message',
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: _choose,
            icon: const Icon(
              Icons.image,
              size: 40,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildPhoto(photoSource) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Image.network(
                photoSource,
              ),
            );
          },
        );
      },
      child: SizedBox(
        height: 250,
        width: 250,
        child: Image.network(
          photoSource,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
