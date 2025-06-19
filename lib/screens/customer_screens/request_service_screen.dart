// ignore_for_file: constant_identifier_names, library_private_types_in_public_api, unused_field, unused_element
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import 'database.dart';

final List<String> categories = [
  'Creative Arts Field',
  'Visual Arts Crafts',
  'Decorative Crafts',
  'Textile Crafts',
  'Culinary Crafts',
  'Performing Arts Crafts',
  'Traditional Crafts',
  'DIY and Hobby Crafts',
];

class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({super.key});

  @override
  _ServiceRequestScreenState createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _uploadImages(requestId) async {
    for (var image in _images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('requests')
          .child(requestId)
          .child(fileName);
      await ref.putFile(image);
    }
  }

  String _selectedServiceCategoryController = categories[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Need A Service ?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        actions: const [
          Image(
            image: AssetImage('assets/images/logo.jpeg'),
            height: 100,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildLocationInput(),
                _buildTitle(),
                _buildDescription(),
                _buildServiceCategoryDropdown(),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 430,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: SizedBox(
                                        height: 300,
                                        width: 300,
                                        child: Image.file(
                                          _images[index],
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
                              child: Image.file(
                                _images[index],
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.lightBlue),
                                    onPressed: () =>
                                        _pickImage(ImageSource.gallery),
                                    child: const Text(
                                      'Pick Image from Gallery',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.lightBlue),
                                    onPressed: () =>
                                        _pickImage(ImageSource.camera),
                                    child: const Text(
                                      'Take a Photo',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildRequestButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Add Your Location in Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _locationController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Enter your location Details',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.lightBlue),
              ),
              filled: true,
              fillColor: Colors.white30,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
            onChanged: (value) {
              _locationController.text = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "please don't leave the field empty!";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Title",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Enter Title of your Request',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.lightBlue),
              ),
              filled: true,
              fillColor: Colors.white30,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "please don't leave the field empty!";
              }
              return null;
            },
            onChanged: (value) {
              _titleController.text = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Description",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Add your Request Details Here',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.lightBlue),
              ),
              filled: true,
              fillColor: Colors.white30,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
            ),
            maxLines: null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "please don't leave the field empty!";
              }
              return null;
            },
            onChanged: (value) {
              _descriptionController.text = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategoryDropdown() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
        color: Colors.white30,
      ),
      child: Center(
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration.collapsed(hintText: ''),
          value: _selectedServiceCategoryController,
          onChanged: (String? newValue) {
            setState(() {
              _selectedServiceCategoryController = newValue!;
            });
          },
          items: categories.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Widget _buildRequestButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          String? userUID = FirebaseAuth.instance.currentUser!.uid;
          String requestId = const Uuid().v4();

          DatabaseService(uid: userUID).requestService(
              _locationController.text,
              _titleController.text,
              _descriptionController.text,
              _selectedServiceCategoryController,
              requestId);
          _uploadImages(requestId);
          Navigator.pop(context);
        }
      },
      child: const Text(
        'Request Service',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
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
                    child: Image.file(
                      _images[index],
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
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _images.removeAt(index);
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
}
