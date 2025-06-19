// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class GridImagePicker extends StatefulWidget {
  const GridImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<GridImagePicker> createState() => _GridImagePickerState();
}

class _GridImagePickerState extends State<GridImagePicker> {
  List<String> imageUrls = [];
  final credential = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    _getImagesFromFirebase();
  }

  Future<void> _getImagesFromFirebase() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(credential)
          .child("/grid_images/");

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: source,
        imageQuality: 100,
      );

      if (pickedImage == null) {
        return;
      }

      File pickedFile = File(pickedImage.path);

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child(credential)
          .child("/grid_images/$fileName");

      await storageRef.putFile(pickedFile);

      final imageUrl = await storageRef.getDownloadURL();

      setState(() {
        imageUrls.add(imageUrl);
        print("image Urls are : $imageUrls");
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void deletePic(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 376,
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    child: Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Delete Picture"),
                  tileColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onTap: () async {
                    final storageRef =
                        FirebaseStorage.instance.refFromURL(imageUrls[index]);
                    final ref = FirebaseStorage.instance
                        .ref()
                        .child(storageRef.fullPath);

                    await ref.delete();
                    Navigator.pop(context);
                    setState(() {
                      imageUrls.removeAt(index);
                    });
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  );
                },
                onLongPress: () {
                  deletePic(index);
                },
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
        MaterialButton(
          onPressed: () {
            _showImageSourceDialog();
          },
          child: Container(
            height: 35,
            width: 150,
            padding: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(17)),
            child: const Text(
              'Add Picture',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
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
}
