import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const NameField(this.label, this.controller, this.hint, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'TiffanyHeavy',
              fontSize: 10,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontFamily: 'TiffanyHeavy',
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
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                errorStyle: const TextStyle(fontSize: 8)),
            validator: (value) {
              List<String> nameParts = value!.split(' ');
              RegExp reg = RegExp(r'[0-9!@#%^&*(),.?":{}|<>]');
              RegExp regex = RegExp(r'\d');
              if (value.isEmpty) {
                return "please dont leave the field empty!";
              } else if (regex.hasMatch(value)) {
                return 'Field must not contain any numbers or symbols';
              } else if (reg.hasMatch(value)) {
                return 'Field must not contain any symbols';
              } else if (nameParts.length != 3) {
                return 'PLease Enter Your 3 Parts Name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
