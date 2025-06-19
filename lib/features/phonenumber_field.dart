import 'package:flutter/material.dart';

class PhoneNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const PhoneNumberField(this.label, this.controller, this.hint, {super.key});

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
              RegExp regex = RegExp(r'^[^a-zA-Z\s]+$');
              RegExp r = RegExp(r'^(079|077|078)\d{7}$');
              if (value == null || value.isEmpty) {
                return "please dont leave the field empty!";
              } else if (!regex.hasMatch(value)) {
                return 'Field must not contain any alphabets or spaces';
              } else if (value.characters.length != 10) {
                return 'phone number must have 10 Digits';
              } else if (!r.hasMatch(value)) {
                return 'Please enter a valid phone number\n starting with 079, 077, or 078';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}
