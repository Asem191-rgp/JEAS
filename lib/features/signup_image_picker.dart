// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class SignupImagePicker extends StatefulWidget {
  const SignupImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<SignupImagePicker> createState() => _SignupImagePickerState();
}

class _SignupImagePickerState extends State<SignupImagePicker> {
  File? _pickedImageFile;
  String imgUrl = "";

  @override
  void initState() {
    super.initState();
    getImageUrl();
  }

  Future<void> _pickImage(ImageSource pick) async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: pick,
        imageQuality: 100,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('ID.jpg');
      await storageRef.putFile(_pickedImageFile!);
      final imageUrl = await storageRef.getDownloadURL();
      print("+++++++++++++++the URL of the image is : $imageUrl ");
      setState(() {
        imgUrl = imageUrl;
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> getImageUrl() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('ID.jpg');
      final url = await ref.getDownloadURL();
      setState(() {
        imgUrl = url;
      });
    } catch (e) {
      print('Error getting image URL: $e');
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
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.lightBlue, width: 3),
      ),
      child: InkWell(
        onTap: _choose,
        child: CircleAvatar(
          radius: 70,
          backgroundImage: imgUrl.isNotEmpty ? NetworkImage(imgUrl) : null,
        ),
      ),
    );
  }
}
